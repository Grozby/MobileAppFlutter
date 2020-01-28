import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_application/models/utility/available_sizes.dart';
import 'package:mobile_application/screens/single_chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/chat/contact_mentor.dart';
import '../../../providers/chat/chat_provider.dart';
import '../../../providers/theming/theme_provider.dart';
import '../../../screens/settings_screen.dart';
import '../../../widgets/general/image_wrapper.dart';
import '../../../widgets/phone/explore/circular_button.dart';

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

mixin ChatTimeConverter {
  Future<String> timeToString(DateTime date) async {
    return await compute(timeToString, date);
  }
}

class InfoBarWidget extends StatelessWidget {
  final double width;

  InfoBarWidget({this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Row(
        children: <Widget>[
          CircularButton(
            assetPath: AssetImages.backArrow,
            alignment: Alignment.centerLeft,
            width: 55,
            height: 55,
            reduceFactor: 0.6,
            onPressFunction: () => backButton(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StreamBuilder(
              stream:
                  Provider.of<ChatProvider>(context).connectionNotifierStream,
              builder: (context, snapshot) {
                return Center(
                  child: AutoSizeText(
                    (!snapshot.hasData || !snapshot.data)
                        ? "Waiting for connection..."
                        : "Connected.",
                    style: Provider.of<ThemeProvider>(context)
                        .getTheme()
                        .textTheme
                        .display3,
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          CircularButton(
            assetPath: AssetImages.settings,
            alignment: Alignment.centerRight,
            width: 55,
            height: 55,
            reduceFactor: 0.6,
            onPressFunction: () => goToSettingPage(context),
          )
        ],
      ),
    );
  }

  void backButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goToSettingPage(BuildContext context) {
    Navigator.of(context).pushNamed(SettingsScreen.routeName);
  }
}

class ChatContentWidget extends StatefulWidget {
  const ChatContentWidget();

  @override
  _ChatContentWidgetState createState() => _ChatContentWidgetState();
}

class _ChatContentWidgetState extends State<ChatContentWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: LayoutBuilder(builder: (ctx, constraints) {
        return ScopedModel<AvailableSizes>(
          model: AvailableSizes(width: constraints.maxWidth),
          child: Container(
            height: constraints.maxHeight,
            child: Column(
              children: <Widget>[
                TabBar(
                  indicatorColor: ThemeProvider.primaryColor,
                  labelColor: ThemeProvider.primaryColor,
                  tabs: [
                    const Tab(text: "All"),
                    const Tab(text: "Accepted"),
                    const Tab(text: "Pending"),
                    const Tab(text: "Refused"),
                  ],
                ),
                Expanded(
                  child: StreamBuilder<bool>(
                      stream: Provider.of<ChatProvider>(context, listen: false)
                          .updateContactsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.data == false) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return TabBarView(
                          children: [
                            MessageList(),
                            MessageList(status: StatusRequest.accepted),
                            MessageList(status: StatusRequest.pending),
                            MessageList(status: StatusRequest.refused),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
        );
      }),
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
    List<ContactMentor> listChats =
        Provider.of<ChatProvider>(context, listen: false)
            .filteredChats(status: widget.status);

    return listChats.isNotEmpty
        ? CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, int index) => ChatTile(chat: listChats[index]),
                  childCount: listChats.length,
                ),
              )
            ],
          )
        : Center(
            child: AutoSizeText(
              "No ${describeEnum(widget.status)} contact requests.",
            ),
          );
  }
}

class ChatTile extends StatelessWidget with ChatTimeConverter {
  final ContactMentor chat;
  final void Function(String) selectChat;

  static const statusColor = {
    StatusRequest.refused: Colors.red,
    StatusRequest.accepted: Colors.green,
    StatusRequest.pending: Colors.yellow,
  };

  ChatTile({@required this.chat, this.selectChat});

  String getMessagePreview() {
    if (chat.messages.isNotEmpty) {
      return chat.messages[0].content;
    } else {
      String response;
      switch (chat.status) {
        case StatusRequest.accepted:
          response = "Contact ${chat.user.completeName} now!";
          break;
        case StatusRequest.pending:
          response = "Waiting for ${chat.user.completeName} response.";
          break;
        case StatusRequest.refused:
          response = "${chat.user.completeName} refused the request.";
          break;
      }
      return response;
    }
  }

  void goToSingleChatPage(BuildContext context) {
    if (chat.status == StatusRequest.accepted) {
      Navigator.of(context).pushNamed(
        SingleChatScreen.routeName,
        arguments: SingleChatArguments(chat.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme =
        Provider.of<ThemeProvider>(context).getTheme().textTheme;

    double maxWidth = ScopedModel.of<AvailableSizes>(context).width;

    return GestureDetector(
      onTap: () => goToSingleChatPage(context),
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.only(
          right: 12,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 12,
              height: 60,
              padding: const EdgeInsets.only(right: 6),
              child: Container(
                width: 6,
                color: statusColor[chat.status],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(60)),
                child: ImageWrapper(
                  assetPath: AssetImages.user,
                  imageUrl: chat.user.pictureUrl,
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
                  ),
                ),
                child: StreamBuilder<bool>(
                    stream: Provider.of<ChatProvider>(context, listen: false)
                        .getTypingNotificationStream(chat.id),
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: AutoSizeText(
                                      chat.user.completeName,
                                      style: textTheme.display1,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Container(
                                    child: AutoSizeText(
                                      (snapshot.hasData && snapshot.data)
                                          ? "Typing..."
                                          : getMessagePreview(),
                                      style: textTheme.subhead,
                                      minFontSize: textTheme.subhead.fontSize,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 60,
                            width: 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                const SizedBox(height: 8),
                                AutoSizeText(
                                  (snapshot.hasData && snapshot.data)
                                      ? ""
                                      : timeToString(
                                          chat.messages.isNotEmpty
                                              ? chat.messages[0].createdAt
                                              : chat.createdAt,
                                        ),
                                  maxLines: 1,
                                ),
                                chat.unreadMessages != 0
                                    ? Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                        child: AutoSizeText(
                                          "${chat.unreadMessages}",
                                          style: textTheme.subhead.copyWith(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
