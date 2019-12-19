import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../../models/users/experiences/academic_degree.dart';
import '../../models/users/experiences/institution.dart';
import '../../models/users/experiences/job.dart';
import '../../models/users/mentee.dart';
import '../../models/users/question.dart';
import '../../models/users/socials/social_account.dart';
import '../../models/users/user.dart';
import '../../providers/user/mentee_ui_data.dart';
import '../../providers/user/user_ui_data.dart';

class UserDataProvider with ChangeNotifier {
  UserUIData behavior;
  HttpRequestWrapper httpRequestWrapper;

  UserDataProvider(this.httpRequestWrapper);

  ///TODO implement load of user data. Fetch from server.
  Future<void> loadUserData() async {
    return await httpRequestWrapper.request<bool>(
        url: "/users/profile",
        typeHttpRequest: TypeHttpRequest.get,
        correctStatusCode: 200,
        onCorrectStatusCode: (response) async {
          switch (response.data["kind"]) {
            case "Mentee":
              this.behavior = MenteeUIData(Mentee.fromJson(response.data));
              break;
            case "Mentor":
              this.behavior = MenteeUIData(Mentee.fromJson(response.data));
              break;
            default:
              throw SomethingWentWrongException.message(
                  "Some error happened on the server side.");
          }
        },
        onIncorrectStatusCode: (_) {
          throw SomethingWentWrongException.message(
            "Couldn't load the explore section. Try again later.",
          );
        },
        onUnknownDioError: (_) {
          throw SomethingWentWrongException();
        });
  }

  User get user => behavior.user;
}
