import '../../models/users/mentee.dart';

import '../../models/users/user.dart';
import 'user_ui_data.dart';

class MenteeUIData extends UserUIData {
  MenteeUIData(Mentee user) : super(user: user);

  Mentee get user => super.user as Mentee;

  @override
  String get remainingTokensString => "You have ${user.tokenWallet} tokens left.";

  @override
  int get tokenCount => user.tokenWallet;
}
