import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/experiences/old_job.dart';
import 'package:mobile_application/models/users/question.dart';

import '../../models/users/experiences/academic_degree.dart';
import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';

class CardProvider with ChangeNotifier {
  List<User> availableUsers;

  User getUser(int index) {
    assert(index >= 0 && index < availableUsers.length);
    return availableUsers[index];
  }

  Mentor getMentor(int index) => getUser(index) as Mentor;

  Mentee getMentee(int index) => getUser(index) as Mentee;

  Future<void> loadCardProvider() async {
    availableUsers = [
      Mentor(
        name: "Bob",
        surname: "Ross",
        bio:
            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
        location: "Mountain View, US",
        company: "Google",
        workingSpecialization: ["Software Engineer", "Front End", "Backend"],
        urlCompanyImage:
            "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
        jobType: "Software Engineer",
        questions: [
          Question(
            question: "Favorite programming languages...",
            answer: "Java, Python, C++",
          ),
          Question(
            question: "Dragoni volanti",
            answer: "E dove trovarli",
          ),
        ],
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
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            university: "Stanford University",
          ),
          OldJob(
            company: "Apple",
            workingRole: "Software engineer",
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
        questions: [
          Question(
            question: "Favorite programming languages...",
            answer: "Java, Python, C++",
          )
        ],
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
          "backend",
        ],
        urlCompanyImage:
            "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
        jobType: "Software Engineer",
        questions: [
          Question(
            question: "Favorite programming languages...",
            answer: "Java, Python, C++",
          ),

        ],
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
