import 'package:json_annotation/json_annotation.dart';

import '../../../models/users/socials/social_account.dart';

part 'twitter_account.g.dart';

@JsonSerializable(explicitToJson: true)
class TwitterAccount extends SocialAccount {
  TwitterAccount(String urlAccount) : super(urlAccount);

  @override
  String get typeAccount => "Twitter";

  ///
  /// Serializable methods
  ///
  factory TwitterAccount.fromJson(Map json) => _$TwitterAccountFromJson(json);

  Map<String, dynamic> toJson() => _$TwitterAccountToJson(this);
}
