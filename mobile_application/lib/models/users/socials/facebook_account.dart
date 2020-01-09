import '../../../models/users/socials/social_account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'facebook_account.g.dart';

@JsonSerializable(explicitToJson: true)
class FacebookAccount extends SocialAccount {
  FacebookAccount(String urlAccount) : super(urlAccount);

  @override
  String get typeAccount => "Facebook";

  ///
  /// Serializable methods
  ///
  factory FacebookAccount.fromJson(Map json) => _$FacebookAccountFromJson(json);

  Map<String, dynamic> toJson() => _$FacebookAccountToJson(this);
}