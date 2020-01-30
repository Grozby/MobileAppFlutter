import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/chat/contact_mentor.dart';
import '../../models/chat/message.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
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
  }
}

class ChatProvider with ChangeNotifier {
  static const String getContactsUrl = "/users/contactrequest";
  static const String getUserIdUri = "/users/userid";
  static const int typingTimeout = 2;

  HttpRequestWrapper httpRequestWrapper;
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
  StreamController<bool> _updateScreenNotifier = BehaviorSubject();

  /// Used for notify a general update in the stored [contacts].
  BehaviorSubject<bool> _updateContactsNotifier;

  /// Used for notify the [InfoBarWidget] of new messages in the home page screen
  BehaviorSubject<int> _numberUnreadMessagesNotifier;

  /// Used for notify the [ChatTile] and [MessageTile]
  /// of new messages and typing notification
  Map<String, ChatNotifier> _mapChatNotifierStreams;

  ChatProvider(this.httpRequestWrapper);

  Stream get updateContactsStream => _updateContactsNotifier.stream;

  Stream get errorNotifierStream => _errorNotifier.stream;

  Stream get connectionNotifierStream => _connectionNotifier.stream;

  Stream get numberUnreadMessagesStream => _numberUnreadMessagesNotifier.stream;

  Stream getTypingNotificationStream(String chatId) =>
      _mapChatNotifierStreams[chatId].typingStream;

  Stream getOnlineStatusStream(String chatId) =>
      _mapChatNotifierStreams[chatId].onlineStatusStream;

  void _clearTypingMapStreams() {
    _mapChatNotifierStreams.forEach((_, t) => t.dispose());
    _mapChatNotifierStreams.clear();
  }

  Future<void> initializeChatProvider({String authToken}) async {
    if (!isInitialized) {
      isInitialized = true;
      this.authToken = authToken;
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

      _connectionNotifier = BehaviorSubject();
      _numberUnreadMessagesNotifier = BehaviorSubject();
      _updateContactsNotifier = BehaviorSubject();
      _errorNotifier = StreamController.broadcast();
      _mapChatNotifierStreams = HashMap();


      await fetchChatContacts();

      _initializeSocket();
    }
  }

  Future<void> fetchChatContacts() async {
    try {
      _updateContactsNotifier.sink.add(false);
      _clearTypingMapStreams();

      contacts = await httpRequestWrapper.request<List<ContactMentor>>(
          url: getContactsUrl,
          correctStatusCode: 200,
          onCorrectStatusCode: (jsonArray) async {
            return jsonArray.data.map<ContactMentor>((json) {
              ContactMentor c = ContactMentor.fromJson(json);
              _mapChatNotifierStreams[c.id] = ChatNotifier();
              return c;
            }).toList();
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException.message(
              "Couldn't load the messages. Try again later.",
            );
          });

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
            ContactMentor c = ContactMentor.fromJson(json.data);
            contacts[contacts.indexOf(c)] = c;
            return;
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException.message(
              "Couldn't load the messages. Try again later.",
            );
          });

      _updateContactsNotifier.sink.add(true);
    } on SomethingWentWrongException catch (e) {
      _updateContactsNotifier.sink.addError(e);
      print(e);
    }
  }

  void addSocketListener(String event, void Function(dynamic) callback,
      {forceBind: false}) {
    if (!socket.hasListeners(event) || forceBind) {
      print("Correctly added Event: $event");
      socket.on(event, (data) {
        print("Event: $event");
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
          'extraHeaders': {'token': authToken},
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
      if (userId != data["userId"]) {
        timeoutTypingNotification.cancel();
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
  }

  void connectionStatus({bool status}) {
    if (status != isConnected) {
      isConnected = status;
      _connectionNotifier.sink.add(isConnected);
    }
  }

  void joinChatWith(String chatId) {
    socket.emit("new_chat", {
      "chatId": chatId,
    });
    currentActiveChatId = chatId;
  }

  void leaveChatWith(String chatId) {
    socket.emit("leave_chat", {
      "chatId": chatId,
    });
    currentActiveChatId = null;
  }

  void sendTypingNotification(String chatId) {
    socket.emit("typing", {
      "chatId": chatId,
    });
  }

  void sendMessage(String message) {
    socket.emit("message", {
      "chatId": currentActiveChatId,
      "userId": userId,
      "content": message,
      "kind": "text",
      "createdAt": DateTime.now().toIso8601String(),
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

  @override
  void dispose() {
    _connectionNotifier.close();
    _updateContactsNotifier.close();
    _errorNotifier.close();
    _updateScreenNotifier.close();
    timeoutTypingNotification?.cancel();
    socket.clearListeners();
    socket.close();
    socket.destroy();

    super.dispose();
  }
}
