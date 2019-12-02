import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';

import 'mentor_question/mentor_question.dart';
import 'user.dart';

part 'mentor.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Mentor extends User {
  List<String> workingSpecialization;

  List<MentorQuestion> questionsForAcceptingRequest;

  Mentor({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required questions,
    @required experiences,
    @required currentJob,
    @required this.workingSpecialization,
    @required this.questionsForAcceptingRequest,
  })  : assert(currentJob != null),
        assert(workingSpecialization != null),
        assert(questionsForAcceptingRequest != null),
        super(
            name: name,
            surname: surname,
            pictureUrl: pictureUrl,
            location: location,
            bio: bio,
            questions: questions,
            experiences: experiences ?? [],
            currentJob: currentJob);

  bool get needsToAnswerQuestions => questionsForAcceptingRequest.length != 0;

  int get howManyQuestionsToAnswer => questionsForAcceptingRequest.length;

  MentorQuestion getMentorQuestionAt(int index) =>
      questionsForAcceptingRequest[index];

  factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);

  Map<String, dynamic> toJson() => _$MentorToJson(this);

  @override
  Color get color => ThemeProvider.mentorColor;

  @override
  Color get cardColor => ThemeProvider.mentorCardColor;
}
