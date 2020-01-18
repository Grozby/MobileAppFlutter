import 'package:flutter/foundation.dart';
import 'package:mobile_application/providers/explore/questions_provider.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../../models/users/answer.dart';
import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';

///
/// Provider used to obtain the Mentor/Mentee information
///
class CardProvider with ChangeNotifier {
  List<User> availableUsers;
  final HttpRequestWrapper httpRequestWrapper;
  List<QuestionsProvider> questionsProvider = List();

  CardProvider(this.httpRequestWrapper);

  String get exploreUrl => "/users/explorestub";

  User getUser(int index) {
    assert(index >= 0 && index < availableUsers.length);
    return availableUsers[index];
  }

  QuestionsProvider getQuestionProvider(int index){
    assert(index >= 0 && index < availableUsers.length);
    return questionsProvider[index];
  }

  Mentor getMentor(int index) => getUser(index) as Mentor;

  Mentee getMentee(int index) => getUser(index) as Mentee;

  Future<void> loadCardProvider() async {
    var json = await httpRequestWrapper.request<dynamic>(
        url: exploreUrl,
        correctStatusCode: 200,
        onCorrectStatusCode: (response) async {
          return response;
        },
        onIncorrectStatusCode: (_) {
          throw SomethingWentWrongException.message(
            "Couldn't load the explore section. Try again later.",
          );
        },
        onUnknownDioError: (_) {
          throw SomethingWentWrongException();
        });

    availableUsers = json.data.map<User>((user) {
      switch (user["kind"]) {
        case "Mentee":
          return Mentee.fromJson(user);
        case "Mentor":
          return Mentor.fromJson(user);
        default:
          throw SomethingWentWrongException.message(
            "Some error happened on the server side.",
          );
      }
    }).toList();

    questionsProvider = availableUsers.map(
      (user) => QuestionsProvider(
        numberOfQuestions: user is Mentor ? user.howManyQuestionsToAnswer : 0,
      ),
    ).toList();

//    availableUsers = [
//      Mentor(
//        name: "Bob",
//        surname: "Ross",
//        bio:
//            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
//        location: "Mountain View, US",
//        workingSpecialization: ["Software Engineer", "Front End", "Backend"],
//        currentJob: Job(
//            institution: Institution(
//              name: "Google",
//              pictureUrl:
//                  "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
//            ),
//            workingRole: "Software Engineer",
//            fromDate: DateTime(2019, 3),),
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
//        experiences: [
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//          Job(
//            institution: Institution(
//              name: "Apple",
//            ),
//            workingRole: "Software engineer",
//            fromDate: DateTime(2019, 12),
//          ),
//        ],
//        questionsForAcceptingRequest: [
//          MentorQuestion(
//            question:
//                "In Software Engineering,briefly explain what the patter Wrapper is used for?",
//            availableTime: 120,
//          ),
//          MentorQuestion(
//            question: "Ma sei megaminchia?",
//            availableTime: 60,
//          ),
//        ],
//        socialAccounts: HashMap<String, SocialAccount>(),
//      ),
//      Mentor(
//        name: "Bobberino",
//        surname: "Ross",
//        bio:
//            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
//        location: "Mountain View, US",
//        currentJob: Job(
//          institution: Institution(
//            name: "Googlerino",
//            pictureUrl: "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
//          ),
//          workingRole: "Software Engineer",
//          fromDate: DateTime(2002, 1),
//        ),
//        workingSpecialization: [
//          "Software Engineer",
//          "Front End",
//        ],
//        questions: [
//          Question(
//            question: "Favorite programming languages...",
//            answer: "Java, Python, C++",
//          )
//        ],
//        pictureUrl:
//            "https://b.thumbs.redditmedia.com/7Zlnm0CUqYG2VIdqpc8QA08cvoINPKTvOZDL2kjfmsI.png",
//        experiences: [
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//        ],
//        questionsForAcceptingRequest: [],
//        socialAccounts: HashMap<String, SocialAccount>(),
//      ),
//      Mentor(
//        name: "Bob",
//        surname: "Ross",
//        bio:
//            "\"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\"",
//        location: "Mountain View, US",
//        workingSpecialization: [
//          "Software Engineer",
//          "Front End",
//          "backend",
//        ],
//        currentJob: Job(
//          institution: Institution(
//            name: "Googlerone",
//            pictureUrl: "https://freeiconshop.com/wp-content/uploads/edd/google-flat.png",
//          ),
//          workingRole: "Software Engineer",
//          fromDate: DateTime(2015, 9),
//        ),
//        questions: [
//          Question(
//            question: "Favorite programming languages...",
//            answer: "Java, Python, C++",
//          ),
//        ],
//        pictureUrl:
//            "https://images.csmonitor.com/csm/2015/06/913184_1_0610-larry_standard.jpg?alias=standard_900x600",
//        experiences: [
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//          AcademicDegree(
//            degreeLevel: "Ph.D",
//            fieldOfStudy: "Computer Science",
//            institution: Institution(
//              name: "Stanford University",
//            ),
//            fromDate: DateTime(2015, 9),
//            toDate: DateTime(2018, 7),
//          ),
//        ],
//        questionsForAcceptingRequest: [],
//        socialAccounts: HashMap<String, SocialAccount>(),
//      ),
//    ];
  }

  Future<void> sendRequestToMentor(List<Answer> answers, String message) async {
    //TODO implement actual request
    print(answers[0].toString());
  }
}
