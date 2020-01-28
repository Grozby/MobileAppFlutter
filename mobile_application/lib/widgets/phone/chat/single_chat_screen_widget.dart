import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/chat/contact_mentor.dart';
import '../../../models/chat/message.dart';
import '../../../providers/chat/chat_provider.dart';
import '../../../providers/theming/theme_provider.dart';
import '../../../screens/user_profile_screen.dart';
import '../../../widgets/general/image_wrapper.dart';
import '../../../widgets/phone/explore/circular_button.dart';

class InfoBarWidget extends StatelessWidget {
  final double width;
  final String chatId;

  InfoBarWidget({
    this.width,
    this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Provider.of<ThemeProvider>(context).getTheme();
    TextTheme textTheme = themeData.textTheme;
    ContactMentor c = Provider.of<ChatProvider>(context).getChatById(chatId);

    return Container(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            fit: FlexFit.tight,
            child: StreamBuilder(
              stream:
                  Provider.of<ChatProvider>(context).connectionNotifierStream,
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
                                width: 40,
                                height: 40,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(40)),
                                  child: ImageWrapper(
                                    assetPath: AssetImages.user,
                                    imageUrl: c.user.pictureUrl,
                                    boxFit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: AutoSizeText(
                                  c.user.completeName,
                                  style: textTheme.display2,
                                  maxLines: 2,
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

class SingleChatContentWidget extends StatelessWidget {
  final String chatId;

  SingleChatContentWidget({this.chatId});

  @override
  Widget build(BuildContext context) {
    ChatProvider chatProvider = Provider.of<ChatProvider>(context);

    return StreamBuilder<bool>(
        stream: chatProvider.updateContactsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == false) {
            return Center(child: CircularProgressIndicator());
          }

          ContactMentor c = chatProvider.getChatById(chatId);

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, int index) {
                    return MessageTile(
                      message: c.messages[c.messages.length - index - 1],
                      whichUser:
                          c.messages[c.messages.length - index - 1].userId !=
                                  chatProvider.userId
                              ? WhichUser.other
                              : WhichUser.current,
                      sameUserAsBefore: index == 0
                          ? true
                          : c.messages[c.messages.length - index - 1].userId ==
                              c.messages[c.messages.length - index].userId,
                    );
                  },
                  childCount: c.messages.length,
                ),
              )
            ],
          );
        });
  }
}

enum WhichUser { current, other }

class MessageTile extends StatelessWidget {
  final Message message;
  final WhichUser whichUser;
  final bool sameUserAsBefore;

  MessageTile({
    this.message,
    this.whichUser,
    this.sameUserAsBefore,
  });

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    ThemeData themeData = themeProvider.getTheme();
    Map<String, Color> chatColors = themeProvider.chatColors;

    double top = sameUserAsBefore ? 4 : 8;
    double bottom = sameUserAsBefore ? 4 : 8;
    double right = whichUser == WhichUser.current ? 16 : 8;
    double left = whichUser == WhichUser.other ? 16 : 8;

    return Container(
      alignment: whichUser == WhichUser.current
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: top,
          bottom: bottom,
          right: right,
          left: left,
        ),
        child: CustomPaint(
          painter: whichUser == WhichUser.current
              ? MessageCurrent(
                  radius: 8,
                  fill: chatColors["currentUser"],
                  border: chatColors["border"],
                )
              : MessageOtherUser(
                  radius: 8,
                  fill: chatColors["otherUser"],
                  border: chatColors["border"],
                ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: AutoSizeText(
              message.content,
              style: themeData.textTheme.body2,
              minFontSize: themeData.textTheme.body1.fontSize,
            ),
          ),
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

  MessageOtherUser(
      {this.radius, this.border, this.offset, this.fill = Colors.red})
      : strokePaint = Paint()
          ..isAntiAlias = true
          ..strokeWidth = 1.0
          ..color = border
          ..style = PaintingStyle.stroke,
        fillPaint = Paint()
          ..isAntiAlias = true
          ..color = fill.withOpacity(0.5)
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
          ..color = fill.withOpacity(0.5)
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
