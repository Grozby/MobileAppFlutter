import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_application/helpers/http_request_wrapper.dart';
import 'package:mobile_application/models/chat/contact_mentor.dart';
import 'package:mobile_application/models/chat/message.dart';
import 'package:mobile_application/models/exceptions/no_internet_exception.dart';
import 'package:mobile_application/models/exceptions/something_went_wrong_exception.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../configuration.dart';

class ChatProvider with ChangeNotifier {
  static const String getContactsUrl = "/users/contactrequest";
  HttpRequestWrapper httpRequestWrapper;
  String authToken;
  Socket socket;
  bool isConnected = false;
  List<ContactMentor> contacts;

  StreamController<String> _errorNotifier = StreamController.broadcast();
  StreamController<bool> _connectionNotifier = BehaviorSubject();
  BehaviorSubject<bool> _loadedContactsNotifier = BehaviorSubject();

  ChatProvider(this.httpRequestWrapper);

  Stream get loadedContactsStream => _loadedContactsNotifier.stream;

  Stream get errorNotifierStream => _errorNotifier.stream;

  Stream get connectionNotifierStream => _connectionNotifier.stream;

  Future<void> initializeChatProvider(String authToken) async {
    this.authToken = authToken;

    if (socket == null) {
      _initializeSocket();
    }

    initializeChatContacts();
  }

  Future<void> initializeChatContacts() async {
    try {
      _loadedContactsNotifier.sink.add(false);

      contacts = await httpRequestWrapper.request<List<ContactMentor>>(
          url: getContactsUrl,
          correctStatusCode: 200,
          onCorrectStatusCode: (jsonArray) async {
            return jsonArray.data
                .map<ContactMentor>((json) => ContactMentor.fromJson(json))
                .toList();
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException.message(
              "Couldn't load the messages. Try again later.",
            );
          });

      _loadedContactsNotifier.sink.add(true);
    } on NoInternetException catch (e) {
      print(e);
    }
  }

  ///
  /// Socket methods
  ///
  void _initializeSocket() {
    socket = io(
      Configuration.serverUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'token': authToken},
      },
    );

    socket.on('connect', (_) => connectionStatus(true));
    socket.on('connect_error', (_) => connectionStatus(false));
    socket.on('disconnect', (_) => connectionStatus(false));

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

    socket.on('message', (data) {
      print(data);
      print(Message.fromJson(data));
    });
  }

  void connectionStatus(bool status) {
    if (status != isConnected) {
      isConnected = status;
      _connectionNotifier.sink.add(isConnected);
    }
  }

  void chatWith(String chatId) {
    socket.emit("new_chat", {
      "chatId": chatId,
      "userToken": authToken,
    });
  }

  ///
  ///
  ///
  List<ContactMentor> filteredChats({StatusRequest status}) {
    if (status == null) {
      return contacts;
    }

    return contacts.where((e) => e.status == status).toList();
  }

  @override
  void dispose() {
    _loadedContactsNotifier.close();
    _errorNotifier.close();
    _connectionNotifier.close();
    super.dispose();
  }
}
