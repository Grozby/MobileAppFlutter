import 'package:flutter/foundation.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/exceptions/no_user_profile_exception.dart';
import '../../models/exceptions/something_went_wrong_exception.dart';
import '../../models/users/mentee.dart';
import '../../models/users/mentor.dart';
import '../../models/users/user.dart';
import '../../providers/user/mentee_ui_data.dart';
import '../../providers/user/user_ui_data.dart';
import 'mentor_ui_data.dart';

enum UserKind {
  Mentee,
  Mentor,
}

class UserDataProvider with ChangeNotifier {
  UserUIData behavior;
  HttpRequestWrapper httpRequestWrapper;

  UserDataProvider(this.httpRequestWrapper);

  Future<void> selectUserKind(UserKind kind) async {
    return await httpRequestWrapper.request<void>(
        url: "/users/signup/decide",
        typeHttpRequest: TypeHttpRequest.post,
        postBody: {"kind": describeEnum(kind)},
        correctStatusCode: 200,
        onCorrectStatusCode: (_) {
          switch (kind) {
            case UserKind.Mentee:
              behavior =
                  MenteeUIData(user: Mentee.fromJson(behavior.user.toJson()));
              break;
            case UserKind.Mentor:
              behavior =
                  MentorUIData(user: Mentor.fromJson(behavior.user.toJson()));
              break;
          }

          return;
        },
        onIncorrectStatusCode: (_) {
          throw SomethingWentWrongException.message(
            "Couldn't load the explore section. Try again later.",
          );
        });
  }

  Future<void> loadUserData() async {
    return await httpRequestWrapper.request<bool>(
        url: "/users/profile",
        typeHttpRequest: TypeHttpRequest.get,
        correctStatusCode: 200,
        onCorrectStatusCode: (response) async {
          switch (response.data["kind"]) {
            case "Mentee":
              behavior = MenteeUIData(user: Mentee.fromJson(response.data));
              break;
            case "Mentor":
              behavior = MentorUIData(user: Mentor.fromJson(response.data));
              break;
            case "User":
              behavior = UserUIData(user: User.fromJson(response.data));
              break;
            default:
              throw SomethingWentWrongException.message(
                "Some error happened on the server side.",
              );
          }

          return;
        },
        onIncorrectStatusCode: (_) {
          throw SomethingWentWrongException.message(
            "Couldn't load the explore section. Try again later.",
          );
        });
  }

  Future<User> loadSpecifiedUserData(String id) async {
    if (id == null) {
      throw NoUserProfileException();
    }

    return await httpRequestWrapper.request<User>(
        url: "/users/profile/$id",
        typeHttpRequest: TypeHttpRequest.get,
        correctStatusCode: 200,
        onCorrectStatusCode: (response) async {
          if (response.data == null) {
            throw NoUserProfileException();
          }
          switch (response.data["kind"]) {
            case "Mentee":
              return Mentee.fromJson(response.data);
              break;
            case "Mentor":
              return Mentor.fromJson(response.data);
              break;
            default:
              throw SomethingWentWrongException.message(
                  "Some error happened on the server side.");
          }
        },
        onIncorrectStatusCode: (_) {
          throw SomethingWentWrongException.message(
            "Couldn't load the selected user section. Try again later.",
          );
        });
  }

  User get user => behavior?.user;
}
