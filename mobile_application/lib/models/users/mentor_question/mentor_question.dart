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
  });

  ///
  /// Serializable methods
  ///
  factory MentorQuestion.fromJson(Map json) => _$MentorQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$MentorQuestionToJson(this);
}
