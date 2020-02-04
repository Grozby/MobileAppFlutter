import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer.g.dart';

@JsonSerializable(explicitToJson: true)
class Answer {
  @required
  String question;
  String textAnswer;
  String audioAnswer;

  Answer({
    this.question,
    this.textAnswer,
    this.audioAnswer,
  });

  ///
  /// Serializable methods
  ///
  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
