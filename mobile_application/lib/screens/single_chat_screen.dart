import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/widgets/phone/chat/single_chat_screen_widget.dart'
    as phone;
import 'package:provider/provider.dart';

import '../providers/chat/chat_provider.dart';

class SingleChatArguments {
  final String id;

  SingleChatArguments(this.id);
}

class SingleChatScreen extends StatefulWidget {
  static const routeName = '/singlechat';

  final SingleChatArguments arguments;

  SingleChatScreen(this.arguments);

  @override
  _SingleChatScreenState createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  ChatProvider chatProviderReference;

  @override
  void initState() {
    super.initState();
    chatProviderReference = Provider.of<ChatProvider>(context, listen: false);
    if (chatProviderReference != null) {
      chatProviderReference.fetchChatContact(widget.arguments.id);
      chatProviderReference.joinChatWith(widget.arguments.id);
    }
  }

  @override
  void dispose() {
    chatProviderReference.leaveChatWith(widget.arguments.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var isSmartPhone = mediaQuery.size.shortestSide < 600;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return isSmartPhone
                ? SingleChatWidget(
                    width: constraints.maxWidth,
                    infoWidget: phone.InfoBarWidget(
                      chatId: widget.arguments.id,
                      width: constraints.maxWidth * 0.85,
                    ),
                    chatContentWidget: phone.SingleChatContentWidget(
                      chatId: widget.arguments.id,
                    ),
                  )
                : SingleChatWidget(
                    width: constraints.maxWidth,
                    infoWidget: phone.InfoBarWidget(
                      chatId: widget.arguments.id,
                      width: constraints.maxWidth * 0.85,
                    ),
                    chatContentWidget: phone.SingleChatContentWidget(
                      chatId: widget.arguments.id,
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class SingleChatWidget extends StatefulWidget {
  final Widget infoWidget;
  final Widget chatContentWidget;
  final double width;

  SingleChatWidget({
    @required this.infoWidget,
    @required this.chatContentWidget,
    @required this.width,
  });

  @override
  _SingleChatWidgetState createState() => _SingleChatWidgetState();
}

class _SingleChatWidgetState extends State<SingleChatWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: Container(
              width: widget.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 1],
                  colors: [
                    Provider.of<ThemeProvider>(context)
                        .getTheme()
                        .primaryColor
                        .withOpacity(0.3),
                    const Color(0xFFFFFF),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
                ),
              ),
              child: widget.infoWidget,
            ),
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
