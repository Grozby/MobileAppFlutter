import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/providers/chat/chat_provider.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:mobile_application/screens/settings_screen.dart';
import 'package:mobile_application/screens/user_profile_screen.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';
import 'package:mobile_application/widgets/phone/explore/circular_button.dart';
import 'package:provider/provider.dart';

class InfoBarWidget extends StatelessWidget {
  final double width;
  final String userPictureUrl;
  final String userId;
  final String userCompleteName;

  InfoBarWidget({
    this.width,
    this.userPictureUrl,
    this.userId,
    this.userCompleteName,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Provider.of<ThemeProvider>(context).getTheme();
    TextTheme textTheme = themeData.textTheme;

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
              Provider
                  .of<ChatProvider>(context)
                  .connectionNotifierStream,
              builder: (context, snapshot) {
                return (!snapshot.hasData || !snapshot.data)
                    ? Center(
                  child: AutoSizeText(
                    "Waiting for connection...",
                    style: textTheme.display3,
                    maxLines: 1,
                  ),
                )
                    : GestureDetector(
                  onTap: () => goToProfilePage(context),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(40)),
                          child: ImageWrapper(
                            assetPath: AssetImages.user,
                            imageUrl: userPictureUrl,
                            boxFit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        child: AutoSizeText(
                          userCompleteName,
                          style: textTheme.display2,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void backButton(BuildContext context) {
    Navigator.of(context).pop();
  }

  void goToProfilePage(BuildContext context) {
    Navigator.of(context).pushNamed(
      UserProfileScreen.routeName,
      arguments: UserProfileArguments(userId),
    );
  }
}

class SingleChatContentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Eccoci!'),
    );
  }
}
