import '../../models/users/mentee.dart';
import 'user_ui_data.dart';

class MenteeUIData extends UserUIData {
  MenteeUIData({Mentee user}) : super(user: user);

  Mentee get user => super.user as Mentee;

  @override
  bool get isInitialized => true;

  @override
  String get noUsersInExploreMessage => "There are no mentors to contact.";

  @override
  String get frontCardButtonText => "Contact now!";
}
