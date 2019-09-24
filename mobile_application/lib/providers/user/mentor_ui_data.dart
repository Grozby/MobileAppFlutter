import 'package:mobile_application/models/exceptions/not_mentee_exception.dart';

import '../../models/users/mentor.dart';

import '../../models/users/user.dart';

import 'user_ui_data.dart';

class MentorUIData extends UserUIData {
  MentorUIData(User user) : super(user: user);

  Mentor get user => super.user as Mentor;

  @override
  String get remainingTokensString => "Find valuable mentees!";

  @override
  int get tokenCount => throw NotMenteeException();
}
