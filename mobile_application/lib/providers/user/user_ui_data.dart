import '../../models/users/user.dart';

class UserUIData {
  User user;

  UserUIData({this.user});

  bool get isInitialized => false;

  String get remainingTokensString => "";

  int get tokenCount => 0;
}
