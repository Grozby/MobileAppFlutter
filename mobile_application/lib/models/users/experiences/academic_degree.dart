import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../helpers/asset_images.dart';
import '../../../models/users/experiences/past_experience.dart';

part 'academic_degree.g.dart';

@JsonSerializable(explicitToJson: true)
class AcademicDegree extends PastExperience {
  String degreeLevel;
  String fieldOfStudy;

  AcademicDegree({
    @required institution,
    @required this.degreeLevel,
    @required this.fieldOfStudy,
    @required fromDate,
    toDate,
  }) : super(
          institution: institution,
          fromDate: fromDate,
          toDate: toDate,
        );

  @override
  String get haveDone => degreeLevel + " in " + fieldOfStudy;

  @override
  String get assetPath => AssetImages.EDUCATION;

  ///
  /// Serializable methods
  ///
  factory AcademicDegree.fromJson(Map json) => _$AcademicDegreeFromJson(json);

  Map<String, dynamic> toJson() => _$AcademicDegreeToJson(this);
}
