import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/answer.dart';
import 'package:mobile_application/models/users/experiences/academic_degree.dart';
import 'package:mobile_application/models/users/experiences/job.dart';
import 'package:mobile_application/models/users/mentor_question/mentor_question.dart';
import 'package:mobile_application/models/users/question.dart';

import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';
import '../../providers/configuration.dart';

///
/// Provider used to obtain the Mentor/Mentee information
///
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
          company: "Google",
          companyImageUrl:
              "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
          workingRole: "Software Engineer",
        ),
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
          Job(
            company: "Apple",
            workingRole: "Software engineer",
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
      ),
      Mentor(
          name: "Bobberino",
          surname: "Ross",
          bio:
              "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
          location: "Mountain View, US",
          currentJob: Job(
            company: "Googlerino",
            companyImageUrl:
                "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
            workingRole: "Software Engineer",
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
          questionsForAcceptingRequest: []),
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
              company: "Google",
              companyImageUrl:
                  "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
              workingRole: "Software Engineer"),
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
          questionsForAcceptingRequest: []),
    ];
  }

  Future<void> sendRequestToMentor(List<Answer> answers, String message) async {
    //TODO implement actual request
    print(answers[0].toString());
  }
}
