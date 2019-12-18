import '../../../models/users/socials/social_account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'linkedin_account.g.dart';

@JsonSerializable(explicitToJson: true)
class LinkedInAccount extends SocialAccount {
  LinkedInAccount(String urlAccount) : super(urlAccount);

  @override
  String get typeAccount => "Linkedin";

  factory LinkedInAccount.fromJson(Map json) => _$LinkedInAccountFromJson(json);

  Map<String, dynamic> toJson() => _$LinkedInAccountToJson(this);
}