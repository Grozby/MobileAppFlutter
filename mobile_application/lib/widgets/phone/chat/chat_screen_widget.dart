import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
          Expanded(
            child: CircularButton(
              assetPath: AssetImages.BACK_ARROW,
              alignment: Alignment.centerLeft,
              width: 55,
              height: 55,
              reduceFactor: 0.6,
              onPressFunction: () => backButton(context),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  Provider.of<ChatProvider>(context).connectionNotifierStream,
              builder: (context, snapshot) {
                return Center(
                  child: AutoSizeText(
                    (!snapshot.hasData || !snapshot.data)
                        ? "Connecting..."
                        : "Connected.",
                    style: Theme.of(context).textTheme.display3,
                    maxLines: 1,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: CircularButton(
              assetPath: AssetImages.SETTINGS,
              alignment: Alignment.centerRight,
              width: 55,
              height: 55,
              reduceFactor: 0.6,
              onPressFunction: () => goToSettingPage(context),
            ),
          ),
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
        return Container(
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
                        .loadedContactsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
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
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) => ChatTile(
                    chat: listChats[0],
                  ),
                  childCount: 10 * listChats.length,
                ),
              )
            ],
          )
        : Center(
            child: Text(
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

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              borderRadius: const BorderRadius.all(const Radius.circular(60)),
              child: ImageWrapper(
                assetPath: AssetImages.USER,
                imageUrl: chat.user.pictureUrl,
                boxFit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: Provider.of<ThemeProvider>(context)
                                .getTheme()
                                .textTheme
                                .subhead,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Flexible(fit: FlexFit.loose, child: const Center()),
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
            ),
          ),
        ],
      ),
    );
  }
}
