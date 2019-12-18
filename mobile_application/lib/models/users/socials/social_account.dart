abstract class SocialAccount {
  String urlAccount;

  String get typeAccount;

  SocialAccount(this.urlAccount) : assert(urlAccount != null);

  Map<String, dynamic> toJson();
}
