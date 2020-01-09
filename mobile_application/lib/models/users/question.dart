import 'package:flutter/foundation.dart';

import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable(explicitToJson: true)
class Question {
  final String question;
  final String answer;

  Question({
    @required this.question,
    @required this.answer,
  });

  factory Question.fromJson(Map json) => _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
