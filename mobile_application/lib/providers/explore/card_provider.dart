import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ryfy/models/chat/contact_mentor.dart';
import 'package:ryfy/providers/theming/theme_provider.dart';

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

  Timer removalElementPostAnimation;

  CardProvider(this.httpRequestWrapper);

  String get exploreUrl => "/users/explore";

  String get sendRequestUrl => "/users/sendrequest";

  String get decideRequest => "/users/deciderequest";

  int get numberAvailableUsers => users.length;

  User getUser(int index) {
    if(index >= 0 && index < users.length){
      return users[index].user;
    }
    return null;
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
      QuestionsProvider qProvider;

      switch (user["kind"]) {
        case "Mentee":
          toAdd = Mentee.fromJson(user);
          qProvider = QuestionsProvider.initialized(
            userId: toAdd.id,
            contactMentor: ContactMentor.fromJson(user["contactInformation"]),
          );
          break;
        case "Mentor":
          toAdd = Mentor.fromJson(user);
          qProvider = QuestionsProvider(
            userId: toAdd.id,
            numberOfQuestions: toAdd.howManyQuestionsToAnswer,
          );
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
          qProvider,
        );
      }
    }).toList() as List<UserContainer>;
  }

  Future<void> sendRequestToMentor(
    QuestionsProvider provider,
    String message,
  ) async {
    await httpRequestWrapper.request<dynamic>(
        url: "$sendRequestUrl/${provider.userId}",
        typeHttpRequest: TypeHttpRequest.post,
        postBody: {
          "startingMessage": message,
          "answers": provider.answers.map((a) => a.toJson()).toList(),
        },
        correctStatusCode: 200,
        onCorrectStatusCode: (response) async {
          notifyListeners();

          indexToRemove = users.indexWhere((e) => e.user.id == provider.userId);
          removalElementPostAnimation = Timer(
            Duration(seconds: 2),
            () => removeUser(provider.userId),
          );
        },
        onIncorrectStatusCode: (_) {
          throw SomethingWentWrongException.message(
            "Couldn't send the request. Try again later.",
          );
        });
  }

  Future<void> decideMenteeRequest(
    QuestionsProvider provider,
    StatusRequest statusRequest,
  ) async {
    await httpRequestWrapper.request<dynamic>(
        url: "$decideRequest/${provider.contactMentor.id}",
        typeHttpRequest: TypeHttpRequest.post,
        postBody: {
          "status": describeEnum(statusRequest),
        },
        correctStatusCode: 200,
        onCorrectStatusCode: (response) async {
          notifyListeners();

          indexToRemove = users.indexWhere((e) => e.user.id == provider.userId);
          removalElementPostAnimation = Timer(
            Duration(seconds: 2),
            () => removeUser(provider.userId),
          );
        },
        onIncorrectStatusCode: (_) {
          throw SomethingWentWrongException.message(
            "Couldn't send the request. Try again later.",
          );
        });
  }

  void removeUser(String id, {BuildContext context}) {
    print("removed!");
    removalElementPostAnimation.cancel();
    indexToRemove = -1;
    users.removeWhere((e) => e.user.id == id);
    if (context != null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: AutoSizeText(
            "Request send succesfully!",
            style: Theme.of(context).textTheme.body1,
          ),
          backgroundColor: Theme.of(context).primaryColorLight,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
          ),
        ),
      );
    }
    notifyListeners();
  }
}
