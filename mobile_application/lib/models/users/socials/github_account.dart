import 'package:json_annotation/json_annotation.dart';

import '../../../models/users/socials/social_account.dart';

part 'github_account.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubAccount extends SocialAccount {
  GithubAccount(String urlAccount) : super(urlAccount);

  @override
  String get typeAccount => "Github";

  ///
  /// Serializable methods
  ///
  factory GithubAccount.fromJson(Map json) => _$GithubAccountFromJson(json);

  Map<String, dynamic> toJson() => _$GithubAccountToJson(this);
}
