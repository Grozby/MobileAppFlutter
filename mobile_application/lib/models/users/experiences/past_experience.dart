import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobile_application/models/users/experiences/institution.dart';

abstract class PastExperience {
  Institution institution;
  DateTime fromDate;
  DateTime toDate;

  String get assetPath;

  String get at => institution.name;

  String get pictureUrl => institution.pictureUrl;

  String get haveDone;

  String get durationExperience =>
      DateFormat.yMMMd().format(fromDate) +
      " - " +
      DateFormat.yMMMd().format(toDate);

  PastExperience({
    @required this.institution,
    @required this.fromDate,
    this.toDate,
  })  : assert(fromDate != null),
        assert(institution != null);
}
