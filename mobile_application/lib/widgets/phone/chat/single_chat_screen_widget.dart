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
import 'package:mobile_application/helpers/overglow_less_scroll_behavior.dart';
import 'package:provider/provider.dart';

import '../../../models/chat/contact_mentor.dart';
import '../../../models/chat/message.dart';
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

  if (now.month > date.month || now.day > date.day) {
    return DateFormat.MMMd('en_US').format(date);
  }

  return DateFormat.Hm().format(date);
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
                          "Waiting for connection...",
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
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      AutoSizeText(
                                        c.user.completeName,
                                        style: textTheme.display2,
                                        maxLines: 2,
                                      ),
                                      IsTypingWidget(
                                        chatProvider
                                            .getMessagePreviewNotificationStream(
                                          widget.chatId,
                                        ),
                                      )
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
  final Stream isTypingStream;

  IsTypingWidget(this.isTypingStream);

  @override
  _IsTypingWidgetState createState() => _IsTypingWidgetState();
}

class _IsTypingWidgetState extends State<IsTypingWidget> {
  TextTheme textTheme;

  @override
  void initState() {
    super.initState();
    textTheme =
        Provider.of<ThemeProvider>(context, listen: false).getTheme().textTheme;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: widget.isTypingStream,
        builder: (context, snapshot) {
          return AutoSizeText(
            (snapshot.hasData && snapshot.data) ? "Typing..." : "",
            style: textTheme.subhead,
            minFontSize: textTheme.subhead.fontSize,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        });
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

  @override
  void initState() {
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

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
              ScrollConfiguration(
                behavior: OverglowLessScrollBehavior(),
                child: CustomScrollView(
                  reverse: true,
                  physics: const ClampingScrollPhysics(),
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, int index) {
                          return MessageTile(
                            message: contact.messages[index],
                            width: widget.width,
                            whichUser: contact.messages[index].userId !=
                                    chatProvider.userId
                                ? WhichUser.other
                                : WhichUser.current,
                            sameUserAsBefore: index == 0
                                ? true
                                : contact.messages[index].userId ==
                                    contact.messages[index - 1].userId,
                          );
                        },
                        childCount: contact.messages.length,
                      ),
                    )
                  ],
                ),
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

  const MessageTile({
    this.message,
    this.width,
    this.whichUser,
    this.sameUserAsBefore,
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



  void initialize(){
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
    if(oldWidget.message.createdAt != widget.message.createdAt){
      initialize();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
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
                  bottom: ((lastLineWidth + hoursWidth - 4) < widget.width - 24)
                      ? 4
                      : 12,
                  left: 8,
                  right: (numberLines == 1 &&
                          (lastLineWidth + hoursWidth - 4) < widget.width - 24)
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
