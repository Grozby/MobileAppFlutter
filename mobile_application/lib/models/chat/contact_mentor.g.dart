// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_mentor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactMentor _$ContactMentorFromJson(Map json) {
  return ContactMentor(
    id: json['_id'] as String,
    user: json['user'] == null
        ? null
        : UserMinimal.fromJson((json['user'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          )),
    startingMessage: json['startingMessage'] as String,
    status: _$enumDecodeNullable(_$StatusRequestEnumMap, json['status']),
    answers: (json['answers'] as List)
        ?.map((e) => e == null
            ? null
            : Answer.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList(),
    messages: (json['messages'] as List)
        ?.map((e) => e == null
            ? null
            : Message.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList(),
    createdAt: ContactMentor.getDateTimeFromString(json['createdAt'] as String),
  );
}

Map<String, dynamic> _$ContactMentorToJson(ContactMentor instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user?.toJson(),
      'startingMessage': instance.startingMessage,
      'status': _$StatusRequestEnumMap[instance.status],
      'answers': instance.answers?.map((e) => e?.toJson())?.toList(),
      'messages': instance.messages?.map((e) => e?.toJson())?.toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$StatusRequestEnumMap = {
  StatusRequest.accepted: 'accepted',
  StatusRequest.refused: 'refused',
  StatusRequest.pending: 'pending',
};
