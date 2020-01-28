import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authentication/authentication_provider.dart';
import '../providers/chat/chat_provider.dart';
import '../providers/user/user_data_provider.dart';
import '../widgets/phone/chat/chat_screen_widget.dart' as phone;

class ChatListScreen extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var isSmartPhone = mediaQuery.size.shortestSide < 600;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return isSmartPhone
                ? ChatWidget(
                    infoWidget: phone.InfoBarWidget(
                      width: constraints.maxWidth * 0.85,
                    ),
                    chatContentWidget: const phone.ChatContentWidget(),
                  )
                : ChatWidget(
                    infoWidget: phone.InfoBarWidget(
                      width: constraints.maxWidth * 0.85,
                    ),
                    chatContentWidget: const phone.ChatContentWidget(),
                  );
          },
        ),
      ),
    );
  }
}

class ChatWidget extends StatefulWidget {
  final Widget infoWidget;
  final Widget chatContentWidget;

  ChatWidget({
    @required this.infoWidget,
    @required this.chatContentWidget,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget>
    with SingleTickerProviderStateMixin {
  StreamSubscription _errorStreamSubscription;
  ChatProvider chatProviderReference;

  @override
  void initState() {
    super.initState();
    chatProviderReference = Provider.of<ChatProvider>(context, listen: false);
    if (chatProviderReference != null) {
      _errorStreamSubscription =
          chatProviderReference.errorNotifierStream.listen(print);

      chatProviderReference.fetchChatContacts();
    }
  }

  @override
  void dispose() {
    chatProviderReference.closeConnections();
    _errorStreamSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: widget.infoWidget,
          ),
          Flexible(
            fit: FlexFit.tight,
            flex: 8,
            child: widget.chatContentWidget,
          ),
        ],
      ),
    );
  }
}
