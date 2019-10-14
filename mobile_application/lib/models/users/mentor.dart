import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mentor_question/mentor_question.dart';
import 'user.dart';

part 'mentor.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Mentor extends User {
  String company;
  String jobType;
  List<String> workingSpecialization;
  String companyImageUrl;
  List<MentorQuestion> questionsForAcceptingRequest;

  Mentor({
    @required name,
    @required surname,
    @required pictureUrl,
    @required location,
    @required bio,
    @required questions,
    @required pastExperiences,
    @required this.company,
    @required this.jobType,
    @required this.workingSpecialization,
    @required this.companyImageUrl,
    @required this.questionsForAcceptingRequest,
  })  : assert(company != null),
        assert(jobType != null),
        assert(workingSpecialization != null),
        assert(companyImageUrl != null),
        assert(questionsForAcceptingRequest != null),
        super(
          name: name,
          surname: surname,
          pictureUrl: pictureUrl,
          location: location,
          bio: bio,
          questions: questions,
          pastExperiences: pastExperiences ?? [],
        );

  bool get needsToAnswerQuestions => questionsForAcceptingRequest.length != 0;

  int get howManyQuestionsToAnswer => questionsForAcceptingRequest.length;

  MentorQuestion getMentorQuestionAt(int index) =>
      questionsForAcceptingRequest[index];

  factory Mentor.fromJson(Map<String, dynamic> json) => _$MentorFromJson(json);

  Map<String, dynamic> toJson() => _$MentorToJson(this);
}
