import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_application/providers/chat/chat_provider.dart';
import 'package:mobile_application/widgets/general/custom_alert_dialog.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).initializeChatProvider(
          "68eac7d55c2877ecf9e6153e393efef2218a768b8086dc5bdf2faa11d9600bb9c710edbe4d8fc9d740fe65eab1386a68f9519a7d2262bac7d0ad2b4eec98773165bc9e5be7ec925a0958a470a67ed218f3a94eb23edf1e2e1715c538e661849ed5ac22ad84235b793e6395d018ae2aba82eefa51d27f3453385e8886f86f0755bbeb63cc5159c2446b32057967e3923e1a467410b82b520b8c9d61d924093b512d5f18e80b17d60ac166ac6394b8567c018d6ef708c43ebd38295dc4fea2958625fdef1b4ba92fc4a105d8bb4de523b9b591a63ca05f26430424b8f5ccb18ef15428c24aea86ccc06e7578fd7f0970da39756753d9ff66bb7d8f7a8611ae04de");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  ChatProvider get chatProvider =>
      Provider.of<ChatProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Test'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: RaisedButton(
                  onPressed: () {
                    chatProvider.chatWith("5e28d2d2715a4352708b4712");
                  },
                ),
              ),
              ChatWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  StreamSubscription errorStreamSubscription;

  @override
  void initState() {
    super.initState();

    var chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider != null) {
      errorStreamSubscription = chatProvider.errorNotifierStream
          .listen((message) => showErrorMessage(message));
    }
  }

  @override
  void dispose() {
    errorStreamSubscription.cancel();
    super.dispose();
  }

  void showErrorMessage(message) {
    showErrorDialog(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder(
          stream: Provider.of<ChatProvider>(context).connectionNotifierStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text("Connecting...");
            }

            return Text(snapshot.data ? "Connected" : "Connecting...");
          },
        ),
        Container(),
      ],
    );
  }
}
