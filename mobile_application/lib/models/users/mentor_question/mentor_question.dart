import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mentor_question.g.dart';

@JsonSerializable(explicitToJson: true)
class MentorQuestion {
  String question;
  int availableTime;

  MentorQuestion({
    @required this.question,
    @required this.availableTime,
  })  : assert(question != null),
        assert(availableTime != null);

  factory MentorQuestion.fromJson(Map json) => _$MentorQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$MentorQuestionToJson(this);
}
