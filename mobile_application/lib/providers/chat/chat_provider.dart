import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_application/helpers/http_request_wrapper.dart';
import 'package:mobile_application/models/chat/contact_mentor.dart';
import 'package:mobile_application/models/chat/message.dart';
import 'package:mobile_application/models/exceptions/no_internet_exception.dart';
import 'package:mobile_application/models/exceptions/something_went_wrong_exception.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../configuration.dart';

class ChatProvider with ChangeNotifier {
  static const String getContactsUrl = "/users/contactrequest";
  HttpRequestWrapper httpRequestWrapper;
  String authToken;
  Socket socket;
  bool isConnected = false;
  List<ContactMentor> contacts;

  StreamController<String> _errorNotifier = StreamController();
  StreamController<bool> _connectionNotifier = StreamController();

  ChatProvider(this.httpRequestWrapper);

  Stream get errorNotifierStream => _errorNotifier.stream;

  Stream get connectionNotifierStream => _connectionNotifier.stream;

  Future<void> initializeChatProvider(String authToken) async {
    this.authToken = authToken;

    try {
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
    } on NoInternetException catch (e) {
      print("");
    }

    _initializeSocket();
  }

  void _initializeSocket() {
    socket = io(
      Configuration.serverUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'token': authToken},
        'timeout': 5000
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

  @override
  void dispose() {
    _errorNotifier.close();
    _connectionNotifier.close();
    super.dispose();
  }
}
