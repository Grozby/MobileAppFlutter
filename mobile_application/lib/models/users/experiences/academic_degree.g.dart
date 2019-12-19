// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_degree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademicDegree _$AcademicDegreeFromJson(Map json) {
  return AcademicDegree(
    institution: PastExperience.getInstitutionFromJson(
        json['institution'] as Map<String, dynamic>),
    degreeLevel: json['degreeLevel'] as String,
    fieldOfStudy: json['fieldOfStudy'] as String,
    fromDate: PastExperience.getDateTimeFromString(json['fromDate'] as String),
    toDate: PastExperience.getDateTimeFromString(json['toDate'] as String),
  );
}

Map<String, dynamic> _$AcademicDegreeToJson(AcademicDegree instance) =>
    <String, dynamic>{
      'institution': instance.institution?.toJson(),
      'fromDate': instance.fromDate?.toIso8601String(),
      'toDate': instance.toDate?.toIso8601String(),
      'degreeLevel': instance.degreeLevel,
      'fieldOfStudy': instance.fieldOfStudy,
    };
