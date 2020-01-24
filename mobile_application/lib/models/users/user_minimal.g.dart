// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_minimal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMinimal _$UserMinimalFromJson(Map json) {
  return UserMinimal(
    id: json['_id'] as String,
    name: json['name'] as String,
    surname: json['surname'] as String,
    pictureUrl: json['pictureUrl'] as String,
  );
}

Map<String, dynamic> _$UserMinimalToJson(UserMinimal instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'pictureUrl': instance.pictureUrl,
    };
