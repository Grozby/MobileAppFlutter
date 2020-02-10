import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/utility/available_sizes.dart';
import '../providers/chat/chat_provider.dart';
import '../providers/theming/theme_provider.dart';
import '../widgets/phone/chat/single_chat_screen_widget.dart' as phone;

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.2],
            colors: [
              Theme.of(context)
                  .primaryColor
                  .withOpacity(0.3),
              const Color(0xFFFFFF),
            ],
          ),
          border: Border(
            bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return ScopedModel<AvailableSizes>(
                model: AvailableSizes(height: constraints.maxHeight),
                child: isSmartPhone
                    ? SingleChatWidget(
                        width: constraints.maxWidth,
                        infoWidget: phone.InfoBarWidget(
                          chatId: widget.arguments.id,
                          width: constraints.maxWidth * 0.85,
                        ),
                        chatContentWidget: phone.SingleChatContentWidget(
                          chatId: widget.arguments.id,
                          width: constraints.maxWidth,
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
                          width: constraints.maxWidth,
                        ),
                      ),
              );
            },
          ),
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
          Container(
            width: widget.width,
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.grey.shade400),
              ),
            ),
            child: widget.infoWidget,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: widget.chatContentWidget,
          ),
        ],
      ),
    );
  }
}
