import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authentication/authentication_provider.dart';
import '../providers/chat/chat_provider.dart';
import '../widgets/phone/chat/chat_screen_widget.dart' as phone;

class MessagesScreen extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
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

  @override
  void initState() {
    super.initState();
    var chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider != null) {
      _errorStreamSubscription =
          chatProvider.errorNotifierStream.listen((message) => print(message));

      chatProvider.initializeChatProvider(
        Provider.of<AuthenticationProvider>(context, listen: false).token,
      );
    }
  }

  void refreshChatProvider() async {
    await Provider.of<ChatProvider>(context, listen: false)
        .fetchChatContacts();
  }

  @override
  void dispose() {
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
