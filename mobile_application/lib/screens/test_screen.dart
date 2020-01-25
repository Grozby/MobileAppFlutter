import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_application/models/chat/contact_mentor.dart';
import 'package:mobile_application/providers/chat/chat_provider.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/widgets/general/custom_alert_dialog.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  ChatProvider get chatProvider =>
      Provider.of<ChatProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ChatWidget(),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    chatProvider.chatWith("5e28d2d2715a4352708b4712");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

mixin ChatTimeConverter {
  String timeToString(DateTime date) {
    DateTime now = DateTime.now();

    if (now.year > date.year) {
      return DateFormat.yMd().format(date);
    }

    if (now.month > date.month || now.day > date.day) {
      return DateFormat.MMMd('en_US').format(date);
    }

    return DateFormat.Hm().format(date);
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

      chatProvider.initializeChatProvider(
          "68eac7d55c2877ecf9e6153e393efef2218a768b8086dc5bdf2faa11d9600bb9c710edbe4d8fc9d740fe65eab1386a68f9519a7d2262bac7d0ad2b4eec98773165bc9e5be7ec925a0958a470a67ed218f3a94eb23edf1e2e1715c538e661849ed5ac22ad84235b793e6395d018ae2aba82eefa51d27f3453385e8886f86f0755bbeb63cc5159c2446b32057967e3923e1a467410b82b520b8c9d61d924093b512d5f18e80b17d60ac166ac6394b8567c018d6ef708c43ebd38295dc4fea2958625fdef1b4ba92fc4a105d8bb4de523b9b591a63ca05f26430424b8f5ccb18ef15428c24aea86ccc06e7578fd7f0970da39756753d9ff66bb7d8f7a8611ae04de");
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
    return DefaultTabController(
      length: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(
            indicatorColor: ThemeProvider.primaryColor,
            labelColor: ThemeProvider.primaryColor,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Accepted"),
              Tab(text: "Pending"),
              Tab(text: "Refused"),
            ],
          ),
          Container(
            height: 400,
            child: TabBarView(
              children: [
                MessageList(),
                Icon(Icons.directions_transit),
                Icon(Icons.directions_bike),
                Icon(Icons.directions_bike),
              ],
            ),
          ),
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
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  final StatusRequest status;

  MessageList({this.status});

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> with ChatTimeConverter {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: Provider.of<ChatProvider>(context).listContactStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          List<ContactMentor> listChats = snapshot.data;

          return LayoutBuilder(
            builder: (ctx, constraints) => Container(
              height: constraints.minHeight,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) => ChatTile(
                        chat: listChats[index],
                      ),
                      childCount: listChats.length,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false).initializeChatContacts();
  }
}

class ChatTile extends StatelessWidget with ChatTimeConverter {
  final ContactMentor chat;

  ChatTile({@required this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(const Radius.circular(60)),
              child: ImageWrapper(
                assetPath: AssetImages.USER,
                imageUrl: chat.user.pictureUrl,
                boxFit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    chat.user.completeName,
                    style: Provider.of<ThemeProvider>(context)
                        .getTheme()
                        .textTheme
                        .display1,
                  ),
                ),
                Container(
                  child: Text(
                    chat.messages.isNotEmpty
                        ? chat.messages[0].content
                        : "Contact ${chat.user.completeName} now!",
                  ),
                ),
              ],
            ),
          ),
          const Expanded(child: const Center()),
          Container(
            alignment: Alignment.topRight,
            width: 50,
            child: Text(
              timeToString(
                chat.messages.isNotEmpty
                    ? chat.messages[0].createdAt
                    : chat.createdAt,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
