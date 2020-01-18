import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../providers/theming/theme_provider.dart';
import 'user.dart';

part 'mentee.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Mentee extends User {
  int tokenWallet;

  Mentee({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required questions,
    @required experiences,
    @required socialAccounts,
    @required currentJob,
    @required this.tokenWallet,
  }) : super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
          questions: questions,
          experiences: experiences,
          socialAccounts: socialAccounts,
          currentJob: currentJob,
        );

  ///
  /// Serializable methods
  ///
  factory Mentee.fromJson(Map<String, dynamic> json) => _$MenteeFromJson(json);

  Map<String, dynamic> toJson() => _$MenteeToJson(this);

  @override
  Color get color => ThemeProvider.menteeColor;

  @override
  Color get cardColor => ThemeProvider.menteeCardColor;

  @override
  int get howManyQuestionsToAnswer => 0;
}
