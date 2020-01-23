import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_application/models/chat/message.dart';
import 'package:mobile_application/widgets/general/custom_alert_dialog.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../configuration.dart';

class ChatProvider with ChangeNotifier {
  String authToken;
  Socket socket;

  StreamController<String> errorNotifier = StreamController();
  StreamController<String> connectionEventNotifier = StreamController();

  ChatProvider(String authToken) {
    this.authToken = authToken;

    socket = io(
      Configuration.serverUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'extraHeaders': {'token': authToken}
      },
    );

    socket.on(
      'connect',
      (_) => print('connect'),
    );
    socket.on(
      'disconnect',
      (_) => print('disconnect'),
    );

    socket.on(
      'error',
      (errorMessage) => errorNotifier.sink.add(errorMessage),
    );
    socket.on(
      'exception',
      (errorMessage) => errorNotifier.sink.add(errorMessage),
    );


    socket.on('message', (data) => print(Message.fromJson(data)));
  }

  void chatWith(String chatId) {
    socket.emit("new_chat", {
      "chatId": chatId,
      "userToken": authToken,
    });
  }

  @override
  void dispose() {
    errorNotifier.close();
    connectionEventNotifier.close();
    super.dispose();
  }
}
