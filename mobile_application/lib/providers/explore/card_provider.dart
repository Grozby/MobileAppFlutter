import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../models/users/answer.dart';
import '../../models/users/experiences/academic_degree.dart';
import '../../models/users/experiences/institution.dart';
import '../../models/users/experiences/job.dart';
import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/mentor_question/mentor_question.dart';
import '../../models/users/question.dart';
import '../../models/users/socials/social_account.dart';
import '../../models/users/user.dart';
import '../../providers/configuration.dart';

///
/// Provider used to obtain the Mentor/Mentee information
///
class CardProvider with ChangeNotifier {
  List<User> availableUsers;

  String get exploreUrl => Configuration.serverUrl + "/users/explorestub";

  User getUser(int index) {
    assert(index >= 0 && index < availableUsers.length);
    return availableUsers[index];
  }

  Mentor getMentor(int index) => getUser(index) as Mentor;

  Mentee getMentee(int index) => getUser(index) as Mentee;

  Future<void> loadCardProvider() async {
//    try {
//      final response = await _httpManager.get(exploreUrl);
//
//      if (response.statusCode == 200) {
//        availableUsers = response.data.map<User>((mentorJson) {
//          Mentor m = Mentor.fromJson(mentorJson);
//          return m;
//        }).toList();
//      }
//      //Otherwise we received something not expected. We throw an error.
//      else {
//        throw SomethingWentWrongException.message(
//          'Something went wrong. We couldn\'t validate the response.',
//        );
//      }
//    } on DioError catch (error) {
//      if (error.type != DioErrorType.RESPONSE) {
//        String errorMessage;
//
//        if (error.type == DioErrorType.DEFAULT) {
//          errorMessage = "Activate the internet connection to connect to RyFy.";
//        } else {
//          errorMessage =
//              "Couldn't connect with the RyFy server. Try again later.";
//        }
//
//        throw NoInternetException(errorMessage);
//      }
//    }

    availableUsers = [
      Mentor(
        name: "Bob",
        surname: "Ross",
        bio:
            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
        location: "Mountain View, US",
        workingSpecialization: ["Software Engineer", "Front End", "Backend"],
        currentJob: Job(
            institution: Institution(
              name: "Google",
              pictureUrl:
                  "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
            ),
            workingRole: "Software Engineer",
            fromDate: DateTime(2019, 3)),
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
        experiences: [
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
          Job(
            institution: Institution(
              name: "Apple",
            ),
            workingRole: "Software engineer",
            fromDate: DateTime(2019, 12),
          ),
        ],
        questionsForAcceptingRequest: [
          MentorQuestion(
            question:
                "In Software Engineering,briefly explain what the patter Wrapper is used for?",
            availableTime: 120,
          ),
          MentorQuestion(
            question: "Ma sei megaminchia?",
            availableTime: 60,
          ),
        ],
        socialAccounts: HashMap<String, SocialAccount>(),
      ),
      Mentor(
        name: "Bobberino",
        surname: "Ross",
        bio:
            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
        location: "Mountain View, US",
        currentJob: Job(
          institution: Institution(
            name: "Googlerino",
            pictureUrl: "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
          ),
          workingRole: "Software Engineer",
          fromDate: DateTime(2002, 1),
        ),
        workingSpecialization: [
          "Software Engineer",
          "Front End",
        ],
        questions: [
          Question(
            question: "Favorite programming languages...",
            answer: "Java, Python, C++",
          )
        ],
        pictureUrl:
            "https://b.thumbs.redditmedia.com/7Zlnm0CUqYG2VIdqpc8QA08cvoINPKTvOZDL2kjfmsI.png",
        experiences: [
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
        ],
        questionsForAcceptingRequest: [],
        socialAccounts: HashMap<String, SocialAccount>(),
      ),
      Mentor(
        name: "Bob",
        surname: "Ross",
        bio:
            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
        location: "Mountain View, US",
        workingSpecialization: [
          "Software Engineer",
          "Front End",
          "backend",
        ],
        currentJob: Job(
          institution: Institution(
            name: "Googlerone",
            pictureUrl: "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
          ),
          workingRole: "Software Engineer",
          fromDate: DateTime(2015, 9),
        ),
        questions: [
          Question(
            question: "Favorite programming languages...",
            answer: "Java, Python, C++",
          ),
        ],
        pictureUrl:
            "https://images.csmonitor.com/csm/2015/06/913184_1_0610-larry_standard.jpg?alias=standard_900x600",
        experiences: [
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
          AcademicDegree(
            degreeLevel: "Ph.D",
            fieldOfStudy: "Computer Science",
            institution: Institution(
              name: "Stanford University",
            ),
            fromDate: DateTime(2015, 9),
            toDate: DateTime(2018, 7),
          ),
        ],
        questionsForAcceptingRequest: [],
        socialAccounts: HashMap<String, SocialAccount>(),
      ),
    ];
  }

  Future<void> sendRequestToMentor(List<Answer> answers, String message) async {
    //TODO implement actual request
    print(answers[0].toString());
  }
}
