import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ryfy/models/chat/contact_mentor.dart';

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
  final String userId;
  ContactMentor contactMentor;
  bool noMoreQuestions = false;

  QuestionsProvider({
    @required this.userId,
    @required this.numberOfQuestions,
  }) : assert(numberOfQuestions != null) {
    currentIndex = 0;
    contactMentor = ContactMentor()..answers = [];

    if (numberOfQuestions == 0) {
      noMoreQuestions = true;
    }
  }

  QuestionsProvider.initialized({
    @required this.userId,
    @required this.contactMentor,
  });

  List<Answer> get answers => contactMentor.answers;

  void insertAnswer({
    String question,
    String textAnswer,
    String audioFilePath,
  }) async {
    contactMentor.answers.add(Answer(
      question: question,
      textAnswer: textAnswer,
      audioAnswer: audioFilePath != null
          ? await compute(getAudioFile, audioFilePath)
          : null,
    ));

    currentIndex++;

    if (numberOfQuestions == currentIndex) {
      noMoreQuestions = true;
    }

    notifyListeners();
  }

  String getAudioFilePath() {
    return "sound${userId}_$currentIndex.aac";
  }

  @override
  void dispose() {
    super.dispose();
  }
}
