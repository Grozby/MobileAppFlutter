import 'package:mobile_application/models/users/user.dart';

abstract class UserUIData {
  User user;

  UserUIData({this.user});

  String get remainingTokensString;
  int get tokenCount;
}