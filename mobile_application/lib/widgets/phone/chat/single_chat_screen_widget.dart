import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mobile_application/widgets/general/custom_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../helpers/overglow_less_scroll_behavior.dart';
import '../../../models/chat/contact_mentor.dart';
import '../../../models/chat/message.dart';
import '../../../models/utility/available_sizes.dart';
import '../../../providers/chat/chat_provider.dart';
import '../../../providers/theming/theme_provider.dart';
import '../../../screens/user_profile_screen.dart';
import '../../../widgets/general/image_wrapper.dart';
import '../../../widgets/phone/explore/circular_button.dart';

String timeToString(DateTime date) {
  DateTime now = DateTime.now();

  if (now.year > date.year) {
    return DateFormat.yMd().format(date);
  }

  return DateFormat.MMMMd('en_US').format(date);
}

mixin ChatTimeConverter {
  Future<String> timeToString(DateTime date) async {
    return await compute(timeToString, date);
  }

  String timeToStringHours(DateTime date) {
    return DateFormat.Hm().format(date);
  }
}

class InfoBarWidget extends StatefulWidget {
  final double width;
  final String chatId;

  InfoBarWidget({
    this.width,
    this.chatId,
  });

  @override
  _InfoBarWidgetState createState() => _InfoBarWidgetState();
}

class _InfoBarWidgetState extends State<InfoBarWidget> {
  ThemeData themeData;
  TextTheme textTheme;
  ChatProvider chatProvider;
  ContactMentor c;

  @override
  void initState() {
    super.initState();
    themeData = Provider.of<ThemeProvider>(context, listen: false).getTheme();
    textTheme = themeData.textTheme;
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    c = chatProvider.getChatById(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularButton(
            assetPath: AssetImages.backArrow,
            alignment: Alignment.centerLeft,
            width: 55,
            height: 55,
            reduceFactor: 0.5,
            onPressFunction: () => backButton(context),
          ),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.tight,
            child: StreamBuilder(
              stream: chatProvider.connectionNotifierStream,
              builder: (context, snapshot) {
                return (!snapshot.hasData || !snapshot.data)
                    ? Center(
                        child: AutoSizeText(
                          "Waiting for network connection...",
                          style: textTheme.display3,
                          maxLines: 1,
                        ),
                      )
                    : InkWell(
                        onTap: () => goToProfilePage(context, c.user.id),
                        child: Container(
                          height: 55,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(width: 4),
                              Container(
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                  child: ImageWrapper(
                                    assetPath: AssetImages.user,
                                    imageUrl: c.user.pictureUrl,
                                    boxFit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 45,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      AutoSizeText(
                                        c.user.completeName,
                                        style: textTheme.display2.copyWith(
                                          fontSize:
                                              textTheme.display2.fontSize - 2,
                                        ),
                                        maxLines: 2,
                                      ),
                                      IsTypingWidget(chatId: widget.chatId),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void backButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goToProfilePage(BuildContext context, String userId) {
    Navigator.of(context).pushNamed(
      UserProfileScreen.routeName,
      arguments: UserProfileArguments(userId),
    );
  }
}

class IsTypingWidget extends StatefulWidget {
  final String chatId;

  IsTypingWidget({@required this.chatId});

  @override
  _IsTypingWidgetState createState() => _IsTypingWidgetState();
}

class _IsTypingWidgetState extends State<IsTypingWidget> {
  Stream typingStatusStream;
  Stream onlineStatusStream;

  TextTheme textTheme;

  @override
  void initState() {
    super.initState();
    textTheme =
        Provider.of<ThemeProvider>(context, listen: false).getTheme().textTheme;
    typingStatusStream = Provider.of<ChatProvider>(context, listen: false)
        .getTypingNotificationStream(widget.chatId);
    onlineStatusStream = Provider.of<ChatProvider>(context, listen: false)
        .getOnlineStatusStream(widget.chatId);
  }

  String getContactPreviewString({bool isTyping, bool isOnline}) =>
      isTyping ? "Typing..." : isOnline ? "Online" : "Offline";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: typingStatusStream,
      builder: (ctx1, isTypingSnap) {
        return StreamBuilder<bool>(
            stream: onlineStatusStream,
            builder: (ctx2, isOnlineSnap) {
              return AutoSizeText(
                (isTypingSnap.hasData && isOnlineSnap.hasData)
                    ? getContactPreviewString(
                        isTyping: isTypingSnap.data,
                        isOnline: isOnlineSnap.data,
                      )
                    : "",
                style: textTheme.overline,
                minFontSize: textTheme.overline.fontSize,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            });
      },
    );
  }
}

class SingleChatContentWidget extends StatefulWidget {
  final String chatId;
  final double width;

  SingleChatContentWidget({this.chatId, this.width});

  @override
  _SingleChatContentWidgetState createState() =>
      _SingleChatContentWidgetState();
}

class _SingleChatContentWidgetState extends State<SingleChatContentWidget> {
  ChatProvider chatProvider;
  ContactMentor contact;
  double availableHeight;

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    availableHeight = ScopedModel.of<AvailableSizes>(context).height;
  }

  WhichUser whichUser(int index) =>
      contact.messages[index].userId != chatProvider.userId
          ? WhichUser.other
          : WhichUser.current;

  bool sameUserAsPreviousMessage(int index) => index == 0
      ? true
      : contact.messages[index].userId == contact.messages[index - 1].userId;

  DateTime maintainDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool dayHasChanged(int index) => index == contact.messages.length - 1
      ? true
      : (contact.messages[index].createdAt.year >
              contact.messages[index + 1].createdAt.year ||
          contact.messages[index].createdAt.month >
              contact.messages[index + 1].createdAt.month ||
          contact.messages[index].createdAt.day >
              contact.messages[index + 1].createdAt.day);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: chatProvider.updateContactsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == false) {
            return Center(child: CircularProgressIndicator());
          }

          contact = chatProvider.getChatById(widget.chatId);

          return Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: ImageWrapper(
                  assetPath:
                      Provider.of<ThemeProvider>(context).backgroundImage,
                  boxFit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: OverglowLessScrollBehavior(),
                      child: CustomScrollView(
                        reverse: true,
                        physics: const ClampingScrollPhysics(),
                        slivers: <Widget>[
                          SliverToBoxAdapter(child: const SizedBox(height: 8)),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, int index) {
                                return MessageTile(
                                  message: contact.messages[index],
                                  width: widget.width,
                                  whichUser: whichUser(index),
                                  sameUserAsBefore:
                                      sameUserAsPreviousMessage(index),
                                  dayHasChanged: dayHasChanged(index),
                                );
                              },
                              childCount: contact.messages.length,
                            ),
                          ),
                          SliverToBoxAdapter(child: const SizedBox(height: 8)),
                        ],
                      ),
                    ),
                  ),
                  InputMessage(),
                ],
              ),
            ],
          );
        });
  }
}

enum WhichUser { current, other }

class MessageTile extends StatefulWidget {
  final Message message;
  final double width;
  final WhichUser whichUser;
  final bool sameUserAsBefore;
  final bool dayHasChanged;

  const MessageTile({
    this.message,
    this.width,
    this.whichUser,
    this.sameUserAsBefore,
    this.dayHasChanged,
  });

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> with ChatTimeConverter {
  ThemeProvider themeProvider;
  ThemeData themeData;
  double top, bottom, right, left, lastLineWidth, hoursWidth;
  int numberLines;
  CustomPainter painter;

  void initialize() {
    top = widget.sameUserAsBefore ? 4 : 8;
    bottom = widget.sameUserAsBefore ? 4 : 8;
    right = widget.whichUser == WhichUser.current ? 16 : 8;
    left = widget.whichUser == WhichUser.other ? 16 : 8;

    painter = widget.whichUser == WhichUser.current
        ? MessageCurrent(
            radius: 8,
            fill: themeProvider.currentUserChatColor,
            border: themeProvider.currentUserBorderChatColor,
          )
        : MessageOtherUser(
            radius: 8,
            fill: themeProvider.otherUserChatColor,
            border: themeProvider.otherUserBorderChatColor,
          );

    final messagePainter = TextPainter(
      text: TextSpan(
        text: widget.message.content,
        style: themeData.textTheme.body2,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: widget.width - 24,
      );
    final List<LineMetrics> metrics = messagePainter.computeLineMetrics();
    lastLineWidth = metrics.last.width;
    numberLines = metrics.length;

    final hourPainter = TextPainter(
      text: TextSpan(
        text: timeToStringHours(widget.message.createdAt),
        style: themeData.textTheme.overline.copyWith(
          fontSize: 13,
          height: 0,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hoursWidth = hourPainter.computeLineMetrics().first.width;
  }

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeData = themeProvider.getTheme();
    initialize();
  }

  @override
  void didUpdateWidget(MessageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.createdAt != widget.message.createdAt) {
      initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.dayHasChanged)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              color: themeProvider.dayNotifierBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Text(timeToString(widget.message.createdAt)),
          ),
        Container(
          alignment: widget.whichUser == WhichUser.current
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(
              top: top,
              bottom: bottom,
              right: right,
              left: left,
            ),
            child: Stack(
              children: <Widget>[
                CustomPaint(
                  painter: painter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 4,
                      bottom:
                          ((lastLineWidth + hoursWidth - 4) < widget.width - 24)
                              ? 4
                              : 12,
                      left: 8,
                      right: (numberLines == 1 &&
                              (lastLineWidth + hoursWidth - 4) <
                                  widget.width - 24)
                          ? 8 + hoursWidth + 4
                          : 8,
                    ),
                    child: AutoSizeText(
                      widget.message.content,
                      style: themeData.textTheme.body2,
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: AutoSizeText(
                    timeToStringHours(widget.message.createdAt),
                    style: themeData.textTheme.overline.copyWith(
                      fontSize: 13,
                      height: 0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MessageOtherUser extends CustomPainter {
  double radius = 8.0;
  Color border;
  Color fill;
  double offset;
  final Paint strokePaint;
  final Paint fillPaint;
  final String text;
  final TextStyle textStyle;

  MessageOtherUser({
    this.text,
    this.textStyle,
    this.radius,
    this.border,
    this.offset,
    this.fill = Colors.red,
  })  : strokePaint = Paint()
          ..isAntiAlias = true
          ..strokeWidth = 1.0
          ..color = border
          ..style = PaintingStyle.stroke,
        fillPaint = Paint()
          ..isAntiAlias = true
          ..color = fill
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(0, size.height - radius)
      ..lineTo(0, radius)
      ..arcTo(Rect.fromLTWH(0, 0, radius * 2, radius * 2), pi, pi / 2, false)
      ..lineTo(size.width - radius, 0)
      ..arcTo(Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
          pi * 3 / 2, pi / 2, false)
      ..lineTo(size.width, size.height - radius)
      ..arcTo(
          Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2,
              radius * 2, radius * 2),
          0,
          pi / 2,
          false)
      ..lineTo(-radius, size.height)
      ..arcToPoint(
        Offset(0, size.height - radius),
        radius: Radius.circular(radius),
        clockwise: false,
      );

    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MessageCurrent extends CustomPainter {
  double radius = 8.0;
  Color border;
  Color fill;
  final Paint strokePaint;
  final Paint fillPaint;

  MessageCurrent({this.radius, this.border, this.fill = Colors.red})
      : strokePaint = Paint()
          ..isAntiAlias = true
          ..strokeWidth = 1.0
          ..color = border
          ..style = PaintingStyle.stroke,
        fillPaint = Paint()
          ..isAntiAlias = true
          ..color = fill
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(size.width, size.height - radius)
      ..arcToPoint(
        Offset(size.width + radius, size.height),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(radius, size.height)
      ..arcTo(
          Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
          pi / 2,
          pi / 2,
          false)
      ..lineTo(0, radius)
      ..arcTo(Rect.fromLTWH(0, 0, radius * 2, radius * 2), pi, pi / 2, false)
      ..lineTo(size.width - radius, 0)
      ..arcTo(Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
          pi * 3 / 2, pi / 2, false)
      ..lineTo(size.width, size.height - radius);

    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class InputMessage extends StatefulWidget {
  @override
  _InputMessageState createState() => _InputMessageState();
}

class _InputMessageState extends State<InputMessage> {
  TextEditingController _controller;
  ThemeProvider _themeProvider;
  double _availableHeight;
  ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _availableHeight = ScopedModel.of<AvailableSizes>(context).height;
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);

    _controller.addListener(sendTypingNotification);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void sendTypingNotification(){
    if (_chatProvider.isConnected && _controller.text.isEmpty) {
      _chatProvider.sendTypingNotification();
    }
  }

  void sendMessage() {
    if(_controller.text.isEmpty){
      return;
    }

    if (_chatProvider.isConnected) {
      _chatProvider.sendMessage(_controller.text);
      _controller.clear();
    } else {
      showErrorDialog(
        context,
        "No internet connection. You can't send the message.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          maxHeight: _availableHeight / 4,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  controller: _controller,
                  style: _themeProvider.getTheme().textTheme.body2,
                  maxLines: null,
                ),
              ),
            ),
            Expanded(
              child: CircularButton(
                height: 45,
                width: 45,
                alignment: Alignment.center,
                assetPath: AssetImages.message,
                onPressFunction: sendMessage,
              ),
            )
          ],
        ),
      ),
    );
  }
}
