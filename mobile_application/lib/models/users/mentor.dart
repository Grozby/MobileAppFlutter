import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../providers/theming/theme_provider.dart';
import 'mentor_question/mentor_question.dart';
import 'user.dart';

part 'mentor.g.dart';

@JsonSerializable(explicitToJson: true)
class Mentor extends User {
  @JsonKey(
    fromJson: getWorkingSpecializationFromJson,
  )
  List<String> workingSpecialization;

  @JsonKey(
    fromJson: getQuestionsForAcceptingRequestFromJson,
  )
  List<MentorQuestion> questionsForAcceptingRequest;

  Mentor({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required questions,
    @required experiences,
    @required socialAccounts,
    @required currentJob,
    @required this.workingSpecialization,
    @required this.questionsForAcceptingRequest,
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

  bool get needsToAnswerQuestions => questionsForAcceptingRequest.length != 0;

  int get howManyQuestionsToAnswer => questionsForAcceptingRequest.length;

  MentorQuestion getMentorQuestionAt(int index) =>
      questionsForAcceptingRequest[index];

  @override
  Color get color => ThemeProvider.mentorColor;

  @override
  Color get cardColor => ThemeProvider.mentorCardColor;

  ///
  /// Serializable methods
  ///
  factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);

  Map<String, dynamic> toJson() => _$MentorToJson(this);

  static List<String> getWorkingSpecializationFromJson(json) {
    return json?.map<String>((e) => e as String)?.toList() ?? <String>[];
  }

  static List<MentorQuestion> getQuestionsForAcceptingRequestFromJson(json) {
    return json
            ?.map<MentorQuestion>(
                (e) => e == null ? null : MentorQuestion.fromJson(e as Map))
            ?.toList() ??
        <MentorQuestion>[];
  }
}
