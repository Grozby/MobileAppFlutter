import 'package:intl/intl.dart';

abstract class PastExperience {
  String pictureUrl;
  DateTime startingTime;
  DateTime endingTime;

  String get assetPath;

  String get at;

  String get haveDone;

  String get durationExperience =>
      DateFormat.yMMMd().format(startingTime) +
      " - " +
      DateFormat.yMMMd().format(endingTime);

  PastExperience({
    this.pictureUrl,
    this.startingTime,
    this.endingTime,
  }) : assert(startingTime != null);
}
