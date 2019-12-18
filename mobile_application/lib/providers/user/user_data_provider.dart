import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/experiences/academic_degree.dart';
import 'package:mobile_application/models/users/experiences/institution.dart';
import 'package:mobile_application/models/users/experiences/job.dart';
import 'package:mobile_application/models/users/socials/social_account.dart';

import '../../models/users/mentee.dart';
import '../../models/users/question.dart';
import '../../models/users/user.dart';
import '../../providers/user/mentee_ui_data.dart';
import '../../providers/user/user_ui_data.dart';

class UserDataProvider with ChangeNotifier {
  UserUIData behavior;

  ///TODO implement load of user data. Fetch from server.
  Future<void> loadUserData() async {
    //REMOVE
    await Future.delayed(Duration(seconds: 1));
    behavior = MenteeUIData(
      Mentee(
        name: "Bob",
        surname: "Ross",
        bio:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        location: "Chicago, USA",
        pictureUrl:
            "https://pbs.twimg.com/profile_images/739783454070431744/f4X-wIsf_400x400.jpg",
        tokenCount: 6,
        currentJob: Job(
            workingRole: "Reseach Assistant",
            institution: Institution(
              name: "University of Illinois at Chicago",
            ),
            fromDate: DateTime(2018, 8)),
        questions: [
          Question(
            question: "Favorite programming languages...",
            answer: "Java, Python, C++",
          )
        ],
        experiences: [
          Job(
            institution: Institution(
              name: "Google",
            ),
            workingRole: "Backend Developer",
            fromDate: DateTime(2016, 3),
            toDate: DateTime(2017, 10),
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
              pictureUrl: "https://identity.stanford.edu/img/block-s-2color.png",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          )
        ],
        socialAccounts: HashMap<String, SocialAccount>(),
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
