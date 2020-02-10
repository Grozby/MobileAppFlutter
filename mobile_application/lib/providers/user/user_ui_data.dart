import '../../models/users/user.dart';

class UserUIData {
  User user;

  UserUIData({this.user});

  bool get isInitialized => false;

  String get noUsersInExploreMessage => "";

  String get frontCardButtonText => "";
}
