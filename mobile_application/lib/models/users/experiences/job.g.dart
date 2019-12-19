// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map json) {
  return Job(
    workingRole: json['workingRole'] as String,
    institution: PastExperience.getInstitutionFromJson(
        json['institution'] as Map<String, dynamic>),
    fromDate: PastExperience.getDateTimeFromString(json['fromDate'] as String),
    toDate: PastExperience.getDateTimeFromString(json['toDate'] as String),
  );
}

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'institution': instance.institution?.toJson(),
      'fromDate': instance.fromDate?.toIso8601String(),
      'toDate': instance.toDate?.toIso8601String(),
      'workingRole': instance.workingRole,
    };
