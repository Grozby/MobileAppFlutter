import 'package:flutter/foundation.dart';
import '../../models/users/user.dart';

import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../providers/user/mentee_ui_data.dart';
import '../../providers/user/mentor_ui_data.dart';
import '../../providers/user/user_ui_data.dart';

class UserDataProvider with ChangeNotifier {
  UserUIData behavior;

  ///TODO implement load of user data. Fetch from server.
  Future<void> loadUserData() async {
    behavior = MenteeUIData(
      Mentee(
        name: "Bob",
        surname: "Ross",
        bio: "I'm Bob Ross",
        location: "US",
        pictureUrl: "https://pbs.twimg.com/profile_images/739783454070431744/f4X-wIsf_400x400.jpg",
        tokenCount: 6,
        favoriteLanguages: ["Java", "Python", "C++"],
      ),
    );

//    behavior = MentorUIData(
//      Mentor(
//        name: "Bob",
//        surname: "Ross",
//        bio: "I'm Bob Ross",
//        location: "US",
//        pictureUrl: null,
//        company: "Google",
//        workingRole: "Software Engineer",
//    "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png"
//      ),
//    );
    return;
  }

  User get user => behavior.user;
}
