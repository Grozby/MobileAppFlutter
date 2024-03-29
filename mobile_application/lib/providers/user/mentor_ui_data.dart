import '../../models/users/mentor.dart';
import 'user_ui_data.dart';

class MentorUIData extends UserUIData {
  MentorUIData({Mentor user}) : super(user: user);

  Mentor get user => super.user as Mentor;

  @override
  bool get isInitialized => true;

  @override
  String get noUsersInExploreMessage => "There are no requests.";

  @override
  String get frontCardButtonText => "Check request!";
}
