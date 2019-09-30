import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';

class AcademicDegree implements PastExperience{
  String university;
  String degreeLevel;
  String fieldOfStudy;

  AcademicDegree({
    @required this.university,
    @required this.degreeLevel,
    @required this.fieldOfStudy,
  });

  @override
  String get at => university;

  @override

  String get haveDone => degreeLevel + " in " + fieldOfStudy;

  @override
  String get assetPath => "assets/images/degree.png";
}
