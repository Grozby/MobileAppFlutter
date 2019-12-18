// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_degree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademicDegree _$AcademicDegreeFromJson(Map json) {
  return AcademicDegree(
    institution: json['institution'],
    degreeLevel: json['degreeLevel'] as String,
    fieldOfStudy: json['fieldOfStudy'] as String,
    fromDate: json['fromDate'],
    toDate: json['toDate'],
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
