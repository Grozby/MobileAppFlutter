import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/experiences/academic_degree.dart';
import 'package:mobile_application/models/users/experiences/job.dart';

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
        location: "US",
        pictureUrl:
            "https://pbs.twimg.com/profile_images/739783454070431744/f4X-wIsf_400x400.jpg",
        tokenCount: 6,
        currentJob: Job(
            workingRole: "Reseach Assistant",
            company: "University of Illinois at Chicago",
            startingTime: DateTime(2018, 8)),
        questions: [
          Question(
            question: "Favorite programming languages...",
            answer: "Java, Python, C++",
          )
        ],
        experiences: [
          Job(
            company: "Google",
            workingRole: "Backend Developer",
            startingTime: DateTime(2016, 3),
            endingTime: DateTime(2017, 10),
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            university: "Stanford University",
            startingTime: DateTime(2015, 9),
            endingTime: DateTime(2018, 7),
          )
        ],
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
