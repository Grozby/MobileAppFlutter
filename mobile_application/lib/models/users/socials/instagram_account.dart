import '../../../models/users/socials/social_account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instagram_account.g.dart';

@JsonSerializable(explicitToJson: true)
class InstagramAccount extends SocialAccount {
  InstagramAccount(String urlAccount) : super(urlAccount);

  @override
  String get typeAccount => "Instagram";

  factory InstagramAccount.fromJson(Map json) => _$InstagramAccountFromJson(json);

  Map<String, dynamic> toJson() => _$InstagramAccountToJson(this);
}