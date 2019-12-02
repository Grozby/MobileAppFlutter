import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../helpers/asset_images.dart';
import '../../../models/users/experiences/past_experience.dart';

part 'academic_degree.g.dart';

@JsonSerializable(explicitToJson: true)
class AcademicDegree extends PastExperience {
  String university;
  String degreeLevel;
  String fieldOfStudy;

  AcademicDegree({
    @required this.university,
    @required this.degreeLevel,
    @required this.fieldOfStudy,
    universityPictureUrl,
    @required startingTime,
    endingTime,
  }) : super(
          pictureUrl: universityPictureUrl,
          startingTime: startingTime,
          endingTime: endingTime,
        );

  @override
  String get at => university;

  @override
  String get haveDone => degreeLevel + " in " + fieldOfStudy;

  @override
  String get assetPath => AssetImages.EDUCATION;

  factory AcademicDegree.fromJson(Map json) => _$AcademicDegreeFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicDegreeToJson(this);
}
