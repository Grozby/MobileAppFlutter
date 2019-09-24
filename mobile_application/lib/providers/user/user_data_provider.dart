import 'package:flutter/foundation.dart';

import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../providers/user/mentee_ui_data.dart';
import '../../providers/user/mentor_ui_data.dart';
import '../../providers/user/user_ui_data.dart';

class UserDataProvider with ChangeNotifier {
  UserUIData behavior;

  ///TODO implement load of user data. Fetch from server.
  Future<void> loadUserData() async {
//    behavior = MenteeUIData(
//      Mentee(
//        name: "Bob",
//        surname: "Ross",
//        bio: "I'm Bob Ross",
//        location: "US",
//        pictureUrl: null,
//        tokenCount: 6,
//      ),
//    );

    behavior = MentorUIData(
      Mentor(
        name: "Bob",
        surname: "Ross",
        bio: "I'm Bob Ross",
        location: "US",
        pictureUrl: null,
        company: "Google",
        workingRole: "Software Engineer",
      ),
    );
    return;
  }
}
