import 'package:json_annotation/json_annotation.dart';

import '../../../models/users/socials/social_account.dart';

part 'instagram_account.g.dart';

@JsonSerializable(explicitToJson: true)
class InstagramAccount extends SocialAccount {
  InstagramAccount(String urlAccount) : super(urlAccount);

  @override
  String get typeAccount => "Instagram";

  ///
  /// Serializable methods
  ///
  factory InstagramAccount.fromJson(Map json) =>
      _$InstagramAccountFromJson(json);

  Map<String, dynamic> toJson() => _$InstagramAccountToJson(this);
}
