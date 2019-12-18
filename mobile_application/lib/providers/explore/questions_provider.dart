import 'package:flutter/material.dart';

import '../../models/users/answer.dart';

///
/// Provider used to store the intermediate answers for a mentor.
///
class QuestionsProvider with ChangeNotifier {
  int numberOfQuestions;
  int currentIndex;
  List<Answer> answers;
  bool noMoreQuestions = false;

  QuestionsProvider({
    @required this.numberOfQuestions,
  }) : assert(numberOfQuestions != null) {
    currentIndex = 0;
    answers = [];

    if (numberOfQuestions == 0) {
      noMoreQuestions = true;
    }
  }

  void insertAnswer(dynamic data) {
    if (data is String) {
      answers.add(Answer(textAnswer: data));
    }
    //TODO implement audio

    currentIndex++;

    if (numberOfQuestions == currentIndex) {
      noMoreQuestions = true;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
