import 'package:flutter/material.dart';
import 'package:mobile_application/screens/messages_screen.dart';
import 'package:mobile_application/screens/user_profile_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/user/user_data_provider.dart';
import 'circular_button_info_bar.dart';

class InfoBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Column(
        children: <Widget>[
          Flexible(
            child: Container(),
            flex: 2,
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CircularButtonInfoBar(
                    assetPath: "assets/images/user.png",
                    onPressFunction: () {
                      Navigator.of(context).pushNamed(
                        UserProfileScreen.routeName,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Explore",
                      style: Theme.of(context).textTheme.display1,
                    ),
                  ),
                  flex: 3,
                ),
                Expanded(
                  child: CircularButtonInfoBar(
                    assetPath: "assets/images/message.png",
                    onPressFunction: () {
                      Navigator.of(context).pushNamed(
                        MessagesScreen.routeName,
                      );
                    },
                  ),
                ),
              ],
            ),
            flex: 3,
          ),
          Flexible(
            child: Align(
              alignment: Alignment.topCenter,
              child: Consumer<UserDataProvider>(
                builder: (context, userData, child) {
                  return Text(
                    userData.behavior.remainingTokensString,
                    style: Theme.of(context).textTheme.display2,
                  );
                },
              ),
            ),
            flex: 3,
          ),
        ],
      ),
    );
  }
}

class ExploreBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        color: Colors.red,
        child: Center(
          child: Text("Card"),
        ),
      ),
      flex: 4,
    );
  }
}
