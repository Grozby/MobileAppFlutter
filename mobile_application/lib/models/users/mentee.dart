import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../models/users/question.dart';
import '../../models/users/socials/social_account.dart';
import '../../providers/theming/theme_provider.dart';
import 'experiences/job.dart';
import 'experiences/past_experience.dart';
import 'user.dart';

part 'mentee.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Mentee extends User {
  int tokenWallet;

  Mentee({
    @required String name,
    @required String surname,
    @required String pictureUrl,
    @required String location,
    @required String bio,
    @required List<Question> questions,
    @required List<PastExperience> experiences,
    @required HashMap<String, SocialAccount> socialAccounts,
    @required Job currentJob,
    List<String> workingSpecialization,
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
          workingSpecialization: workingSpecialization,
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
