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
    startingTime: json['startingTime'],
    endingTime: json['endingTime'],
  )..pictureUrl = json['pictureUrl'] as String;
}

Map<String, dynamic> _$AcademicDegreeToJson(AcademicDegree instance) =>
    <String, dynamic>{
      'pictureUrl': instance.pictureUrl,
      'startingTime': instance.startingTime?.toIso8601String(),
      'endingTime': instance.endingTime?.toIso8601String(),
      'university': instance.university,
      'degreeLevel': instance.degreeLevel,
      'fieldOfStudy': instance.fieldOfStudy,
    };
