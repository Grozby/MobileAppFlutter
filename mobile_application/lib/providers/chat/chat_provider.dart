import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ryfy/providers/notification/notification_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/chat/contact_mentor.dart';
import '../../models/chat/message.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../../providers/database/database_provider.dart';
import '../configuration.dart';

/// Class relative to the events of the user we can chat with.
/// The user can type, send messages, be online/offline.
class ChatNotifier {
  StreamController<bool> _typingNotifier = BehaviorSubject();
  StreamController<bool> _onlineStatusNotifier = BehaviorSubject();
  bool _isTyping;
  bool _isOnline;

  ChatNotifier() {
    isTypingNotifier(value: false);
    isOnlineNotifier(value: false);
  }

  Stream get typingStream => _typingNotifier.stream;

  bool get isTyping => _isTyping;

  void isTypingNotifier({bool value}) {
    _isTyping = value;
    _typingNotifier.sink.add(_isTyping);
  }

  Stream get onlineStatusStream => _onlineStatusNotifier.stream;

  bool get isOnline => _isOnline;

  void isOnlineNotifier({bool value}) {
    _isOnline = value;
    _onlineStatusNotifier.sink.add(_isOnline);
  }

  void dispose() {
    _typingNotifier.close();
    _onlineStatusNotifier.close();
  }
}

class ChatProvider with ChangeNotifier {
  static const String getContactsUrl = "/users/contactrequest";
  static const String getUserIdUri = "/users/userid";
  static const int typingTimeout = 2;

  HttpRequestWrapper httpRequestWrapper;
  DatabaseProvider databaseProvider;
  String fcmToken;

  String authToken;
  String userId;
  Socket socket;
  bool isConnected = false;
  bool isInitialized = false;
  List<ContactMentor> contacts;
  Timer timeoutTypingNotification;
  String currentActiveChatId;

  StreamController<String> _errorNotifier;
  StreamController<bool> _connectionNotifier;
  StreamController<bool> _updateScreenNotifier;

  /// Used for notify a general update in the stored [contacts].
  BehaviorSubject<bool> _updateContactsNotifier;

  /// Used for notify the [InfoBarWidget] of new messages in the home page screen
  BehaviorSubject<int> _numberUnreadMessagesNotifier;

  /// Used for notify the [ChatTile] and [MessageTile]
  /// of new messages and typing notification
  Map<String, ChatNotifier> _mapChatNotifierStreams;

  StreamSubscription pushNotificationListener;

  ChatProvider({
    @required this.httpRequestWrapper,
    @required this.databaseProvider,
    @required this.fcmToken,
  });

  Stream get updateContactsStream => _updateContactsNotifier.stream;

  Stream get errorNotifierStream => _errorNotifier.stream;

  Stream get connectionNotifierStream => _connectionNotifier.stream;

  Stream get numberUnreadMessagesStream =>
      _numberUnreadMessagesNotifier?.stream;

  Stream getTypingNotificationStream(String chatId) =>
      _mapChatNotifierStreams[chatId].typingStream;

  Stream getOnlineStatusStream(String chatId) =>
      _mapChatNotifierStreams[chatId].onlineStatusStream;

  void _clearTypingMapStreams() {
    _mapChatNotifierStreams?.forEach((_, t) => t.dispose());
    _mapChatNotifierStreams?.clear();
  }

  Future<void> initializeChatProvider({
    String authToken,
    Stream<ReceivedNotification> pushNotificationStream,
  }) async {
    if (!isInitialized) {
      isInitialized = true;
      this.authToken = authToken;

      _connectionNotifier = BehaviorSubject();
      _numberUnreadMessagesNotifier = BehaviorSubject();
      _updateContactsNotifier = BehaviorSubject();
      _errorNotifier = StreamController.broadcast();
      _mapChatNotifierStreams = HashMap();
      _updateScreenNotifier = BehaviorSubject();
      pushNotificationListener =
          pushNotificationStream.listen(pushNotificationManager);
      contacts = await loadContactMentorsFromDB();

      try {
        this.userId = await httpRequestWrapper.request<String>(
            url: getUserIdUri,
            correctStatusCode: 200,
            onCorrectStatusCode: (json) async {
              return json.data["id"];
            },
            onIncorrectStatusCode: (_) {
              throw SomethingWentWrongException.message(
                "Couldn't load the messages. Try again later.",
              );
            });

        await fetchChatContacts();

        _initializeSocket();
      } on SomethingWentWrongException catch (_) {
        isInitialized = false;
      }
    }
  }

  Future<void> fetchChatContacts({bool loadingAnimationUi: true}) async {
    try {
      if (loadingAnimationUi) {
        _updateContactsNotifier.sink.add(false);
      }

      List<String> retrievedIds = [];

      await httpRequestWrapper.request<void>(
          url: getContactsUrl,
          correctStatusCode: 200,
          onCorrectStatusCode: (jsonArray) async {
            jsonArray.data.forEach((json) async {
              /// If the mentor is already present, we update its messages
              /// Otherwise, we simply add the mentor
              ContactMentor newC = ContactMentor.fromJson(json);
              retrievedIds.add(newC.id);

              if (contacts.contains(newC)) {
                var contactIndex = contacts.indexOf(newC);

                if (contacts[contactIndex].status != newC.status) {
                  contacts[contactIndex].status = newC.status;
                  updateContactMentorInDB(newC);
                }

                ///Add messages is any new
                var messagesToAdd = newC.messages
                    .where((m) => !contacts[contactIndex].messages.contains(m))
                    .toList();

                if (messagesToAdd.isNotEmpty) {
                  messagesToAdd.forEach(
                    (Message m) => contacts[contactIndex].messages.insert(0, m),
                  );
                  await saveMessagesToDb(messagesToAdd, newC.id);
                }
              } else {
                contacts.add(newC);
                _mapChatNotifierStreams[newC.id] = ChatNotifier();
                await saveNewContactMentorInDB(newC);
              }
            });
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException.message(
              "Couldn't load the messages. Try again later.",
            );
          });

      List<ContactMentor> toRemove =
          contacts.where((c) => !retrievedIds.contains(c.id)).toList();
      toRemove.forEach((c) {
        deleteContactMentorInDB(c.id);
        contacts.remove(c);
      });

      /// Sort the contacts by last received message.
      contacts.sort(
        (c1, c2) {
          DateTime timeC1 = c1.messages.isNotEmpty
              ? c1.messages.first.createdAt
              : c1.createdAt;
          DateTime timeC2 = c2.messages.isNotEmpty
              ? c2.messages.first.createdAt
              : c2.createdAt;
          return -timeC1.difference(timeC2).inMilliseconds;
        },
      );

      contacts.forEach(
        (c) => c.messages.sort(
          (m1, m2) {
            return -m1.createdAt.difference(m2.createdAt).inMilliseconds;
          },
        ),
      );

      /// Notify the UI of unread messages
      _numberUnreadMessagesNotifier.sink.add(
        contacts.where((c) => c.unreadMessages(userId) != 0).length,
      );

      /// Notify the UI of successful update of the contacts
      _updateContactsNotifier.sink.add(true);
    } on SomethingWentWrongException catch (e) {
      _updateContactsNotifier.sink.addError(e);
      print(e);
    }
  }

  Future<void> fetchChatContact(String chatId) async {
    try {
      _updateContactsNotifier.sink.add(false);

      await httpRequestWrapper.request<void>(
          url: "$getContactsUrl/$chatId",
          correctStatusCode: 200,
          onCorrectStatusCode: (json) async {
            ContactMentor newC = ContactMentor.fromJson(json.data);
            var contactIndex = contacts.indexOf(newC);
            var messagesToAdd = newC.messages
                .where((m) => !contacts[contactIndex].messages.contains(m))
                .toList();

            if (messagesToAdd.isNotEmpty) {
              messagesToAdd.forEach(
                (m) => contacts[contactIndex].messages.insert(0, m),
              );
              await saveMessagesToDb(messagesToAdd, newC.id);
            }

            ///Remove messages if not present anymore
            var messagesToRemove = contacts[contactIndex]
                .messages
                .where((m) => !newC.messages.contains(m))
                .toList();

            if (messagesToRemove.isNotEmpty) {
              messagesToRemove.forEach(
                (m) => contacts[contactIndex].messages.remove(m),
              );
              await removeMessagesToDb(messagesToRemove, newC.id);
            }

            contacts[contactIndex].messages.sort(
              (m1, m2) {
                return -m1.createdAt.difference(m2.createdAt).inMilliseconds;
              },
            );
            return;
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException.message(
              "Couldn't load the messages. Try again later.",
            );
          });

      _numberUnreadMessagesNotifier.sink.add(
        contacts.where((c) => c.unreadMessages(userId) != 0).length,
      );

      _updateContactsNotifier.sink.add(true);
    } on SomethingWentWrongException catch (e) {
      _updateContactsNotifier.sink.addError(e);
      print(e);
    }
  }

  void pushNotificationManager(ReceivedNotification notification) {
    if (notification.payload["userId"] != userId) {
      return;
    }

    if (notification.payload["ryfy_action"] == "UPDATE") {
      fetchChatContacts(loadingAnimationUi: false);
      return;
    }
    if (notification.payload["ryfy_action"] == "MESSAGE" &&
        notification.payload["chat_id"] == currentActiveChatId) {
      return;
    }

    NotificationProvider.showNotificationMediaStyle(notification.payload);
  }

  void addSocketListener(String event, void Function(dynamic) callback,
      {forceBind: false}) {
    if (!socket.hasListeners(event) || forceBind) {
      debugPrint("Correctly added Event: $event");
      socket.on(event, (data) {
        debugPrint("Event: $event");
        callback(data);
      });
    }
  }

  ///
  /// Socket methods
  ///
  void _initializeSocket() {
    if (socket == null) {
      socket = io(
        Configuration.serverUrl,
        <String, dynamic>{
          'transports': ['websocket'],
          'extraHeaders': {'token': authToken, 'fcmToken': fcmToken},
          "reconnect": true,
          "forceNew": true,
        },
      );
    } else {
      socket.connect();
    }

    addSocketListener(
      'connect',
      (_) => connectionStatus(status: true),
      forceBind: true,
    );
    addSocketListener('reconnect', (_) => connectionStatus(status: true));
    addSocketListener('connect_error', (_) => connectionStatus(status: false));
    addSocketListener('disconnect', (_) => connectionStatus(status: false));

    addSocketListener('had_active_chat', (_) {
      if (currentActiveChatId != null) {
        joinChatWith(currentActiveChatId);
      }
    });

    addSocketListener(
      'connect_timeout',
      (errorMessage) => _errorNotifier.sink.add("Timeout."),
    );
    addSocketListener(
      'error',
      (errorMessage) => _errorNotifier.sink.add(errorMessage),
    );
    addSocketListener(
      'exception',
      (errorMessage) => _errorNotifier.sink.add(errorMessage),
    );

    /// Check online/offline
    addSocketListener(
      'online',
      (data) {
        if (data["userId"] != userId &&
            !_mapChatNotifierStreams[data["chatId"]].isOnline) {
          _mapChatNotifierStreams[data["chatId"]].isOnlineNotifier(value: true);
        }
      },
    );
    addSocketListener(
      'offline',
      (data) {
        if (data["userId"] != userId &&
            _mapChatNotifierStreams[data["chatId"]] != null &&
            _mapChatNotifierStreams[data["chatId"]].isOnline) {
          _mapChatNotifierStreams[data["chatId"]]
              .isOnlineNotifier(value: false);
        }
      },
    );

    ///Messages methods
    addSocketListener('typing', (data) {
      if (data["userId"] != userId) {
        if (!_mapChatNotifierStreams[data["chatId"]].isTyping) {
          _mapChatNotifierStreams[data["chatId"]].isTypingNotifier(value: true);
        } else {
          timeoutTypingNotification.cancel();
        }

        timeoutTypingNotification = Timer(Duration(seconds: typingTimeout), () {
          _mapChatNotifierStreams[data["chatId"]]
              .isTypingNotifier(value: false);
        });
      }
    });

    addSocketListener('message', (data) {
      ContactMentor c = contacts.firstWhere((c) => data["chatId"] == c.id);

      c.messages.insert(
        0,
        Message.fromJson({
          "userId": data["userId"],
          "content": data["content"],
          "kind": data["kind"],
          "createdAt": data["createdAt"].toString(),
          "isRead": data["isRead"]
        }),
      );

      /// Sort the contacts by last received message.
      contacts.sort(
        (c1, c2) {
          DateTime timeC1 = c1.messages.isNotEmpty
              ? c1.messages.first.createdAt
              : c1.createdAt;
          DateTime timeC2 = c2.messages.isNotEmpty
              ? c2.messages.first.createdAt
              : c2.createdAt;
          return -timeC1.difference(timeC2).inMilliseconds;
        },
      );

      if (userId != data["userId"]) {
        timeoutTypingNotification?.cancel();

        /// This also updates the last message
        _mapChatNotifierStreams[data["chatId"]].isTypingNotifier(value: false);

        _numberUnreadMessagesNotifier.sink.add(
          contacts.where((c) => c.unreadMessages(data["chatId"]) != 0).length,
        );
      }

      if (currentActiveChatId != null) {
        _updateContactsNotifier.sink.add(true);
      }
    });

    addSocketListener('updated_contact_request', (data) {
      contacts.firstWhere((c) => data["chatId"] == c.id).status =
          (data["status"] == 'accepted'
              ? StatusRequest.accepted
              : StatusRequest.refused);
      _updateContactsNotifier.sink.add(true);
    });

    addSocketListener('new_contact_request', (data) {
      fetchChatContacts(loadingAnimationUi: false);
    });
  }

  void connectionStatus({bool status}) {
    if (status != isConnected) {
      isConnected = status;
      _connectionNotifier.sink.add(isConnected);
    }
  }

  void joinChatWith(String chatId) {
    socket?.emit("new_chat", {
      "chatId": chatId,
    });
    currentActiveChatId = chatId;
  }

  void leaveChatWith(String chatId) {
    socket?.emit("leave_chat", {
      "chatId": chatId,
    });
    currentActiveChatId = null;
  }

  void sendTypingNotification() {
    socket?.emit("typing", {
      "chatId": currentActiveChatId,
    });
  }

  void sendMessage(String message) {
    socket?.emit("message", {
      "chatId": currentActiveChatId,
      "userId": userId,
      "content": message,
      "kind": "text",
      "createdAt": DateTime.now().toUtc().toIso8601String(),
    });
  }

  List<ContactMentor> filteredChats({StatusRequest status}) {
    if (status == null) {
      return contacts;
    }
    return contacts.where((e) => e.status == status).toList();
  }

  ContactMentor getChatById(String chatId) {
    return contacts.firstWhere((e) => e.id == chatId);
  }

  ///
  /// Database methods
  ///
  Future<List<ContactMentor>> loadContactMentorsFromDB() async {
    debugPrint("DB - Loading contacts");
    final database = await databaseProvider.getDatabase();
    var results = await database.query(DatabaseProvider.contactsTableName);

    return results.isEmpty
        ? []
        : (await Future.wait(results.map<Future<ContactMentor>>(
            (map) async {
              var c = ContactMentor.fromJson(jsonDecode(map["json"]));
              debugPrint("DB - Loading CM: ${c.id}");
              debugPrint("DB - Loading Messages for CM: ${c.id}");
              final messagesResult = await database.query(
                DatabaseProvider.messagesTableName,
                columns: ['id', 'json'],
                where: '"contact_id" = ?',
                whereArgs: [c.id],
                orderBy: "date DESC",
              );

              c.messages = messagesResult.isNotEmpty
                  ? (await Future.wait(
                      messagesResult.map<Future<Message>>(
                        (m) async => Message.fromJson(jsonDecode(m["json"])),
                      ),
                    ))
                      .toList(growable: true)
                  : <Message>[];

              _mapChatNotifierStreams[c.id] = ChatNotifier();
              return c;
            },
          ).toList()))
            .toList(growable: true);
  }

  Future<void> saveNewContactMentorInDB(ContactMentor c) async {
    debugPrint("DB - Saving CM: ${c.id}");
    final database = await databaseProvider.getDatabase();

    var batch = database.batch();
    batch.insert(
      DatabaseProvider.contactsTableName,
      {
        "id": c.id,
        "json": jsonEncode(ContactMentor.cloneWithoutMessages(c).toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    for (var message in c.messages) {
      batch.insert(
        DatabaseProvider.messagesTableName,
        {
          "id": message.id,
          "contact_id": c.id,
          "json": jsonEncode(message.toJson()),
          "date": message.createdAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteContactMentorInDB(String cId) async {
    debugPrint("DB - deleting CM: $cId");
    final database = await databaseProvider.getDatabase();

    var batch = database.batch();

    batch.delete(
      DatabaseProvider.messagesTableName,
      where: '"contact_id" = ?',
      whereArgs: [cId],
    );

    batch.delete(
      DatabaseProvider.contactsTableName,
      where: '"id" = ?',
      whereArgs: [cId],
    );

    await batch.commit(noResult: true);
  }

  Future<void> updateContactMentorInDB(ContactMentor c) async {
    debugPrint("DB - Update CM: ${c.id}");
    final database = await databaseProvider.getDatabase();

    database.update(
      DatabaseProvider.contactsTableName,
      {
        "id": c.id,
        "json": jsonEncode(ContactMentor.cloneWithoutMessages(c).toJson()),
      },
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<void> saveMessagesToDb(List<Message> messages, String chatId) async {
    debugPrint("DB - Saving Messages for CM: $chatId");
    final database = await databaseProvider.getDatabase();
    var batch = database.batch();

    for (var m in messages) {
      batch.insert(
        DatabaseProvider.messagesTableName,
        {
          "id": m.id,
          "contact_id": chatId,
          "json": jsonEncode(m.toJson()),
          "date": m.createdAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    batch.commit(noResult: true);
  }

  Future<void> removeMessagesToDb(List<Message> messages, String chatId) async {
    debugPrint("DB - Delete Messages for CM: $chatId");
    final database = await databaseProvider.getDatabase();
    var batch = database.batch();

    for (var m in messages) {
      batch.delete(
        DatabaseProvider.messagesTableName,
        where: '"contact_id" = ? AND "id" = ?',
        whereArgs: [chatId, m.id],
      );
    }
    batch.commit(noResult: true);
  }

  @override
  void dispose() {
    _connectionNotifier?.close();
    _updateContactsNotifier?.close();
    _errorNotifier?.close();
    _updateScreenNotifier?.close();
    _numberUnreadMessagesNotifier?.close();
    timeoutTypingNotification?.cancel();
    fcmToken = null;

    authToken = null;
    userId = null;
    isConnected = false;
    isInitialized = false;
    contacts = [];
    currentActiveChatId = null;

    _clearTypingMapStreams();

    pushNotificationListener?.cancel();

    socket?.clearListeners();
    socket?.close();
    socket?.destroy();

    super.dispose();
  }
}
