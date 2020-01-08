import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/users/experiences/institution.dart';

abstract class PastExperience {
  @JsonKey(fromJson: getInstitutionFromJson)
  Institution institution;
  @JsonKey(fromJson: getDateTimeFromString)
  DateTime fromDate;
  @JsonKey(fromJson: getDateTimeFromString)
  DateTime toDate;

  PastExperience({
    @required this.institution,
    @required this.fromDate,
    this.toDate,
  })  : assert(fromDate != null),
        assert(institution != null);

  String get assetPath;

  String get at => institution.name;

  String get pictureUrl => institution.pictureUrl;

  String get haveDone;

  String get durationExperience =>
      DateFormat.yMMMd().format(fromDate) +
      " - " +
      DateFormat.yMMMd().format(toDate);

  static Institution getInstitutionFromJson(Map<String, dynamic> json) {
    return Institution.fromJson(json);
  }

  static DateTime getDateTimeFromString(String string) {
    return string == null ? null : DateTime.parse(string);
  }
}
