import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/users/answer.dart';

String getAudioFile(String filePath) {
  try {
    File file = File(filePath);
    if (!file.existsSync()) return null;

    return String.fromCharCodes((file..openRead()).readAsBytesSync());
  } catch (e) {
    print(e);
    return null;
  }
}

///
/// Provider used to store the intermediate answers for a mentor.
///
class QuestionsProvider with ChangeNotifier {
  int numberOfQuestions;
  int currentIndex;
  final String mentorId;
  List<Answer> answers;
  bool noMoreQuestions = false;

  QuestionsProvider({
    @required this.mentorId,
    @required this.numberOfQuestions,
  }) : assert(numberOfQuestions != null) {
    currentIndex = 0;
    answers = [];

    if (numberOfQuestions == 0) {
      noMoreQuestions = true;
    }
  }

  void insertAnswer({
    String question,
    String textAnswer,
    String audioFilePath,
  }) async {
    answers.add(Answer(
      question: question,
      textAnswer: textAnswer,
      audioAnswer: await compute(getAudioFile, audioFilePath),
    ));

    currentIndex++;

    if (numberOfQuestions == currentIndex) {
      noMoreQuestions = true;
    }

    notifyListeners();
  }

  String getAudioFilePath() {
    return "sound${mentorId}_$currentIndex.aac";
  }

  @override
  void dispose() {
    super.dispose();
  }
}
