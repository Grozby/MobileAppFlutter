import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/exceptions/no_internet_exception.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';
import '../../providers/configuration.dart';

class CardProvider with ChangeNotifier {
  List<User> availableUsers;
  final Dio _httpManager;

  String get exploreUrl => Configuration.serverUrl + "/users/explorestub";

  CardProvider(this._httpManager);

  User getUser(int index) {
    assert(index >= 0 && index < availableUsers.length);
    return availableUsers[index];
  }

  Mentor getMentor(int index) => getUser(index) as Mentor;

  Mentee getMentee(int index) => getUser(index) as Mentee;

  Future<void> loadCardProvider() async {
    ///TODO check all possible errors!!!!
    try {
      final response = await _httpManager.get(exploreUrl);

      if (response.statusCode == 200) {
        availableUsers = response.data.map<User>((mentorJson) {
          Mentor m = Mentor.fromJson(mentorJson);
          return m;
        }).toList();
      }
      //Otherwise we received something not expected. We throw an error.
      else {
        throw SomethingWentWrongException.message(
          'Something went wrong. We couldn\'t validate the response.',
        );
      }
    } on DioError catch (error) {
      if (error.type != DioErrorType.RESPONSE) {
        throw NoInternetException("Couldn't connect to the server. Retry later.");
      }
    }

//    availableUsers = [
//      Mentor(
//        name: "Bob",
//        surname: "Ross",
//        bio:
//            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
//        location: "Mountain View, US",
//        company: "Google",
//        workingSpecialization: ["Software Engineer", "Front End", "Backend"],
//        companyImageUrl:
//            "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
//        jobType: "Software Engineer",
//        questions: [
//          Question(
//            question: "Favorite programming languages...",
//            answer: "Java, Python, C++",
//          ),
//          Question(
//            question: "Dragoni volanti",
//            answer: "E dove trovarli",
//          ),
//        ],
//        pictureUrl:
//            "https://images.csmonitor.com/csm/2015/06/913184_1_0610-larry_standard.jpg?alias=standard_900x600",
//        pastExperiences: [
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//          OldJob(
//            company: "Apple",
//            workingRole: "Software engineer",
//          ),
//        ],
//      ),
//      Mentor(
//        name: "Bobberino",
//        surname: "Ross",
//        bio:
//            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
//        location: "Mountain View, US",
//        company: "Googlerino",
//        workingSpecialization: [
//          "Software Engineer",
//          "Front End",
//        ],
//        companyImageUrl:
//            "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
//        jobType: "Software Engineer",
//        questions: [
//          Question(
//            question: "Favorite programming languages...",
//            answer: "Java, Python, C++",
//          )
//        ],
//        pictureUrl:
//            "https://b.thumbs.redditmedia.com/7Zlnm0CUqYG2VIdqpc8QA08cvoINPKTvOZDL2kjfmsI.png",
//        pastExperiences: [
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//        ],
//      ),
//      Mentor(
//        name: "Bob",
//        surname: "Ross",
//        bio:
//            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
//        location: "Mountain View, US",
//        company: "Google",
//        workingSpecialization: [
//          "Software Engineer",
//          "Front End",
//          "backend",
//        ],
//        companyImageUrl:
//            "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
//        jobType: "Software Engineer",
//        questions: [
//          Question(
//            question: "Favorite programming languages...",
//            answer: "Java, Python, C++",
//          ),
//        ],
//        pictureUrl:
//            "https://images.csmonitor.com/csm/2015/06/913184_1_0610-larry_standard.jpg?alias=standard_900x600",
//        pastExperiences: [
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            university: "Stanford University",
//          ),
//        ],
//      ),
//    ];
  }
}
