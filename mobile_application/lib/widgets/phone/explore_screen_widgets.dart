import 'package:flutter/material.dart';
import 'package:mobile_application/models/users/mentor.dart';
import 'package:mobile_application/models/users/user.dart';
import 'package:mobile_application/screens/messages_screen.dart';
import 'package:mobile_application/screens/user_profile_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/user/user_data_provider.dart';
import 'circular_button_info_bar.dart';
import 'explore_card.dart';

class InfoBarWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: Container(),
          flex: 2,
        ),
        Flexible(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Consumer<UserDataProvider>(
                  builder: (context, userProvider, child) {
                    return CircularButtonInfoBar(
                      assetPath: "user.png",
                      imageUrl: userProvider.user.pictureUrl,
                      onPressFunction: () {
                        Navigator.of(context).pushNamed(
                          UserProfileScreen.routeName,
                        );
                      },
                    );
                  },

                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Explore",
                    style: Theme
                        .of(context)
                        .textTheme
                        .display3,
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
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1
                      .copyWith(
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                );
              },
            ),
          ),
          flex: 2,
        ),
      ],
    );
  }
}

class ExploreBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: ExploreCard(
        user: Mentor(
          name: "Bob",
          surname: "Ross",
          bio: "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
          location: "Mountain View, US",
          company: "Google",
          workingSpecialization: ["Software Engineer"],
          urlCompanyImage:
          "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
          jobType: "Software Engineer",
          favoriteLanguages: ["Java", "Python", "C++"],
          pictureUrl:
          "https://images.csmonitor.com/csm/2015/06/913184_1_0610-larry_standard.jpg?alias=standard_900x600",
        ),
      ),
    );
  }
}
