// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map json) {
  return Job(
    company: json['company'] as String,
    workingRole: json['workingRole'] as String,
    startingTime: json['startingTime'],
    endingTime: json['endingTime'],
  )..pictureUrl = json['pictureUrl'] as String;
}

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'pictureUrl': instance.pictureUrl,
      'startingTime': instance.startingTime?.toIso8601String(),
      'endingTime': instance.endingTime?.toIso8601String(),
      'company': instance.company,
      'workingRole': instance.workingRole,
    };
