// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_degree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademicDegree _$AcademicDegreeFromJson(Map json) {
  return AcademicDegree(
    university: json['university'] as String,
    degreeLevel: json['degreeLevel'] as String,
    fieldOfStudy: json['fieldOfStudy'] as String,
    universityPictureUrl: json['universityPictureUrl'] as String,
  );
}

Map<String, dynamic> _$AcademicDegreeToJson(AcademicDegree instance) =>
    <String, dynamic>{
      'university': instance.university,
      'degreeLevel': instance.degreeLevel,
      'fieldOfStudy': instance.fieldOfStudy,
      'universityPictureUrl': instance.universityPictureUrl,
    };
