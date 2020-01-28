import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/chat/contact_mentor.dart';
import '../../models/chat/message.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../configuration.dart';

class MessagePreviewController {
  StreamController<bool> updateNotification = BehaviorSubject();
  StreamController<bool> typingNotifier = PublishSubject();

  void notifiedWith({bool value}) => updateNotification.sink.add(value);

  void sendNotification(bool value) => typingNotifier.sink.add(value);

  Stream get typingNotificationStream => updateNotification.stream;

  Stream get typingNotifierStream => typingNotifier.stream;

  void dispose() {
    updateNotification.close();
    typingNotifier.close();
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
  bool isTyping = false;
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
  /// Used for notify the [MessageTile] of new messages and typing notification
  Map<String, StreamController<bool>> _mapMessagePreviewStreams;

  ChatProvider(this.httpRequestWrapper);

  Stream get updateContactsStream => _updateContactsNotifier.stream;

  Stream get errorNotifierStream => _errorNotifier.stream;

  Stream get connectionNotifierStream => _connectionNotifier.stream;

  Stream get numberUnreadMessagesStream => _numberUnreadMessagesNotifier.stream;

  Stream getMessagePreviewNotificationStream(String id) =>
      _mapMessagePreviewStreams[id].stream;

  void _clearTypingMapStreams() {
    _mapMessagePreviewStreams.forEach((_, t) => t.close());
    _mapMessagePreviewStreams.clear();
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
      _mapMessagePreviewStreams = HashMap();

      _initializeSocket();

      await fetchChatContacts();
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
              _mapMessagePreviewStreams[c.id] = BehaviorSubject();
              _mapMessagePreviewStreams[c.id].sink.add(false);
              return c;
            }).toList();
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException.message(
              "Couldn't load the messages. Try again later.",
            );
          });

      _numberUnreadMessagesNotifier.sink.add(
        contacts.where((c) => c.unreadMessages != 0).length,
      );

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

    ///Messages methods

    addSocketListener('typing', (data) {
      if (data["userId"] != userId) {
        if (!isTyping) {
          isTyping = true;
          _mapMessagePreviewStreams[data["chatId"]].sink.add(isTyping);
        } else {
          timeoutTypingNotification.cancel();
        }

        timeoutTypingNotification = Timer(Duration(seconds: typingTimeout), () {
          isTyping = false;
          _mapMessagePreviewStreams[data["chatId"]].sink.add(isTyping);
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
      c.unreadMessages += data["isRead"] ? 0 : 1;

      timeoutTypingNotification.cancel();
      isTyping = false;
      _mapMessagePreviewStreams[data["chatId"]].sink.add(isTyping);

      _numberUnreadMessagesNotifier.sink.add(
        contacts.where((c) => c.unreadMessages != 0).length,
      );
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

  List<ContactMentor> filteredChats({StatusRequest status}) {
    if (status == null) {
      return contacts;
    }
    return contacts.where((e) => e.status == status).toList();
  }

  ContactMentor getChatById(String chatId) {
    return contacts.firstWhere((e) => e.id == chatId);
  }

  void closeConnections() {
    isConnected = false;
    isTyping = false;
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
