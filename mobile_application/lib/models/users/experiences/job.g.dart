// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map json) {
  return Job(
    company: json['company'] as String,
    workingRole: json['workingRole'] as String,
    companyImageUrl: json['companyImageUrl'] as String,
  );
}

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'company': instance.company,
      'workingRole': instance.workingRole,
      'companyImageUrl': instance.companyImageUrl,
    };
