import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../../models/users/answer.dart';
import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';
import '../../providers/explore/questions_provider.dart';

class UserContainer {
  User user;
  QuestionsProvider questionsProvider;

  UserContainer(this.user, this.questionsProvider);
}

///
/// Provider used to obtain the Mentor/Mentee information
///
class CardProvider with ChangeNotifier {
  List<UserContainer> users = [];
  final HttpRequestWrapper httpRequestWrapper;

  int indexToRemove = -1;
  String idToRemove;
  Timer removalElementPostAnimation;

  CardProvider(this.httpRequestWrapper);

  String get exploreUrl => "/users/explore";

  String get sendRequestUrl => "/users/sendrequest";

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
          QuestionsProvider(
              numberOfQuestions: toAdd.howManyQuestionsToAnswer,
              mentorId: toAdd.id),
        );
      }
    }).toList() as List<UserContainer>;
  }

  Future<void> sendRequestToMentor(
    QuestionsProvider provider,
    String message,
  ) async {
    indexToRemove = users.indexWhere((e) => e.user.id == provider.mentorId);
    idToRemove = provider.mentorId;
    removalElementPostAnimation = Timer(
      Duration(seconds: 10),
      () => removeUser(),
    );

    notifyListeners();

//    await httpRequestWrapper.request<dynamic>(
//        url: "$sendRequestUrl/${provider.mentorId}",
//        typeHttpRequest: TypeHttpRequest.post,
//        postBody: {
//          "startingMessage": message,
//          "answers": provider.answers.map((a) => a.toJson()).toList(),
//        },
//        correctStatusCode: 200,
//        onCorrectStatusCode: (response) async {
//          indexToRemove =
//              users.indexWhere((e) => e.user.id == provider.mentorId);
//          notifyListeners();
//
//          removalElementPostAnimation = Timer(Duration(seconds: 1), () {
//            removeUser(indexToRemove);
//          });
//        },
//        onIncorrectStatusCode: (_) {
//          throw SomethingWentWrongException.message(
//            "Couldn't send the request. Try again later.",
//          );
//        });
  }

  void removeUser() {
    print("removed!");
    removalElementPostAnimation.cancel();
    users.removeWhere((e) => e.user.id == idToRemove);

    indexToRemove = -1;
    idToRemove = "";
    notifyListeners();
  }
}
