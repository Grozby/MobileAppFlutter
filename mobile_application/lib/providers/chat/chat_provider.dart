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

class TypingNotifier {
  StreamController<bool> typingNotification = BehaviorSubject();
  StreamController<bool> typingNotifier = PublishSubject();

  void setTypingNotifier(bool value) => typingNotification.sink.add(value);

  void sendNotification(bool value) => typingNotifier.sink.add(value);

  Stream get typingNotificationStream => typingNotification.stream;

  Stream get typingNotifierStream => typingNotifier.stream;

  void dispose() {
    typingNotification.close();
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
  List<ContactMentor> contacts;
  Timer timeoutTypingNotification;
  String currentActiveChatId;

  StreamController<String> _errorNotifier = StreamController.broadcast();
  StreamController<bool> _connectionNotifier = BehaviorSubject();
  StreamController<bool> _updateScreenNotifier = BehaviorSubject();
  BehaviorSubject<bool> _updateContactsNotifier = BehaviorSubject();
  BehaviorSubject<int> _numberUnreadMessagesNotifier = BehaviorSubject();
  Map<String, TypingNotifier> _mapTypingStreams = HashMap();

  ChatProvider(this.httpRequestWrapper);

  Stream get updateContactsStream => _updateContactsNotifier.stream;

  Stream get errorNotifierStream => _errorNotifier.stream;

  Stream get connectionNotifierStream => _connectionNotifier.stream;

  Stream get numberUnreadMessagesStream => _numberUnreadMessagesNotifier.stream;

  Stream getTypingNotificationStream(String id) =>
      _mapTypingStreams[id].typingNotificationStream;

  PublishSubject getTypingNotifierStream(String id) =>
      _mapTypingStreams[id].typingNotifierStream;

  void _clearTypingMapStreams() {
    _mapTypingStreams.forEach((_, t) => t.dispose());
    _mapTypingStreams.clear();
  }

  Future<void> initializeChatProvider({String authToken, String userId}) async {
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

    _initializeSocket();

    await fetchChatContacts();
  }

  Future<void> initializeForChatScreen() async {
    _errorNotifier = StreamController.broadcast();
    _updateContactsNotifier = BehaviorSubject();
    _mapTypingStreams = HashMap();

    _initializeSocket();
    await fetchChatContacts();
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
              _mapTypingStreams[c.id] = TypingNotifier();
              _mapTypingStreams[c.id].setTypingNotifier(false);
              return c;
            }).toList();
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException.message(
              "Couldn't load the messages. Try again later.",
            );
          });

      _numberUnreadMessagesNotifier.sink.add(
        contacts
            .where((c) => c.unreadMessages != 0)
            .length,
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

    socket.on('connect', (_) {
      connectionStatus(true);
    });
    socket.on('connect_error', (_) => connectionStatus(false));
    socket.on('disconnect', (_) => connectionStatus(false));

    socket.on('had_active_chad', (_) {
      if(currentActiveChatId != null){
        joinChatWith(currentActiveChatId);
      }
    });

    socket.on(
      'connect_timeout',
          (errorMessage) => _errorNotifier.sink.add("Timeout."),
    );
    socket.on(
      'error',
          (errorMessage) => _errorNotifier.sink.add(errorMessage),
    );
    socket.on(
      'exception',
          (errorMessage) => _errorNotifier.sink.add(errorMessage),
    );

    ///Messages methods
    socket.on('typing', (data) {
      print("typing");
      if (data["userId"] != userId) {
        if (!isTyping) {
          isTyping = true;
          _mapTypingStreams[data["chatId"]].setTypingNotifier(isTyping);
        } else {
          timeoutTypingNotification.cancel();
        }

        timeoutTypingNotification = Timer(Duration(seconds: typingTimeout), () {
          isTyping = false;
          _mapTypingStreams[data["chatId"]].setTypingNotifier(isTyping);
        });
      }
    });

    socket.on('message', (data) {
      print("messagione");
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
      c.unreadMessages += 1;

      timeoutTypingNotification.cancel();
      isTyping = false;
      _mapTypingStreams[data["chatId"]].setTypingNotifier(isTyping);

      _numberUnreadMessagesNotifier.sink.add(
        contacts
            .where((c) => c.unreadMessages != 0)
            .length,
      );
    });

    socket.on('updated_contact_request', (data) {
      contacts
          .firstWhere((c) => data["chatId"] == c.id)
          .status =
      (data["status"] == 'accepted'
          ? StatusRequest.accepted
          : StatusRequest.refused);
      _updateContactsNotifier.sink.add(true);
    });
  }

  void connectionStatus(bool status) {
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
