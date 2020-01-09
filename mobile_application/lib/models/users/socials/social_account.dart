abstract class SocialAccount {
  String urlAccount;

  String get typeAccount;

  SocialAccount(this.urlAccount);

  Map<String, dynamic> toJson();
}
