import 'package:flutter/foundation.dart';
import 'package:mobile_application/providers/explore/questions_provider.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../../models/users/answer.dart';
import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';

class UserContainer {
  User user;
  QuestionsProvider questionsProvider;

  UserContainer(this.user, this.questionsProvider);
}

///
/// Provider used to obtain the Mentor/Mentee information
///
class CardProvider with ChangeNotifier {
  List<UserContainer> users = List();
  final HttpRequestWrapper httpRequestWrapper;

  CardProvider(this.httpRequestWrapper);

  String get exploreUrl => "/users/explorestub";

  int get numberAvailableUsers => users.length;

  User getUser(int index) {
    assert(index >= 0 && index < users.length);
    return users[index].user;
  }

  QuestionsProvider getQuestionProvider(int index) {
    assert(index >= 0 && index < users.length);
    return users[index].questionsProvider;
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

    users = json.data.map<UserContainer>((user) {
      User toAdd;

      switch (user["kind"]) {
        case "Mentee":
          toAdd = Mentee.fromJson(user);
          break;
        case "Mentor":
          toAdd = Mentor.fromJson(user);
          break;
        default:
          throw SomethingWentWrongException.message(
            "Some error happened on the server side.",
          );
      }

      UserContainer checkExistence =
          users.firstWhere((t) => t.user == toAdd, orElse: () => null);

      if (checkExistence != null) {
        return checkExistence;
      } else {
        return UserContainer(
          toAdd,
          QuestionsProvider(numberOfQuestions: toAdd.howManyQuestionsToAnswer, mentorId: toAdd.id),
        );
      }
    }).toList();
  }

  Future<void> sendRequestToMentor(List<Answer> answers, String message) async {
    //TODO implement actual request
    print(answers[0].toString());
  }
}
