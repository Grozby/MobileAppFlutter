// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'institution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Institution _$InstitutionFromJson(Map json) {
  return Institution(
    name: json['name'] as String,
    pictureUrl: json['pictureUrl'] as String,
  );
}

Map<String, dynamic> _$InstitutionToJson(Institution instance) =>
    <String, dynamic>{
      'pictureUrl': instance.pictureUrl,
      'name': instance.name,
    };
