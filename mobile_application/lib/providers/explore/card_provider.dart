import 'package:flutter/foundation.dart';
import '../../models/users/mentee.dart';

import '../../models/users/experiences/academic_degree.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';

class CardProvider with ChangeNotifier {
  List<User> availableUsers;
  int selectedUserIndex;

  User get selectedUser => availableUsers[selectedUserIndex];

  User getUser(int index) {
    assert(index >= 0 && index < availableUsers.length);
    return availableUsers[index];
  }

  Mentor getMentor(int index) => getUser(index) as Mentor;

  Mentee getMentee(int index) => getUser(index) as Mentee;

  void changeSelectedUser(Verse verse) {
    switch (verse) {
      case Verse.LEFT:
        if (selectedUserIndex - 1 < 0) selectedUserIndex -= 1;
        break;
      case Verse.RIGHT:
        if (selectedUserIndex + 1 >= availableUsers.length)
          selectedUserIndex += 1;
        break;
      default:
        throw Exception("Not a Verse passed as parameter");
    }
    notifyListeners();
  }

  Future<void> loadCardProvider() async {
    selectedUserIndex = 0;
    availableUsers = [
      Mentor(
        name: "Bob",
        surname: "Ross",
        bio:
            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
        location: "Mountain View, US",
        company: "Google",
        workingSpecialization: [
          "Software Engineer",
          "Front End",
        ],
        urlCompanyImage:
            "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
        jobType: "Software Engineer",
        favoriteLanguages: ["Java", "Python", "C++"],
        pictureUrl:
            "https://images.csmonitor.com/csm/2015/06/913184_1_0610-larry_standard.jpg?alias=standard_900x600",
        pastExperiences: [
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            university: "Stanford University",
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            university: "Stanford University",
          ),
        ],
      ),
      Mentor(
        name: "Bobberino",
        surname: "Ross",
        bio:
            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
        location: "Mountain View, US",
        company: "Googlerino",
        workingSpecialization: [
          "Software Engineer",
          "Front End",
        ],
        urlCompanyImage:
            "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
        jobType: "Software Engineer",
        favoriteLanguages: ["Java", "Python", "C++"],
        pictureUrl:
            "https://b.thumbs.redditmedia.com/7Zlnm0CUqYG2VIdqpc8QA08cvoINPKTvOZDL2kjfmsI.png",
        pastExperiences: [
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            university: "Stanford University",
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            university: "Stanford University",
          ),
        ],
      ),
    ];

    await Future.delayed(Duration(milliseconds: 50));
  }
}

enum Verse {
  LEFT,
  RIGHT,
}
