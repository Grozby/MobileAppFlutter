import 'package:flutter/foundation.dart';

class Question {
  final String question;
  final String answer;

  Question({
    @required this.question,
    @required this.answer,
  })  : assert(question != null),
        assert(answer != null);
}
