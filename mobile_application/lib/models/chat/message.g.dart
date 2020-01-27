// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map json) {
  return Message(
    userId: json['userId'] as String,
    content: json['content'] as String,
    kind: json['kind'] as String,
    createdAt: Message.getDateTimeFromString(json['createdAt'] as String),
    isRead: json['isRead'] as bool,
  );
}

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'userId': instance.userId,
      'content': instance.content,
      'kind': instance.kind,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isRead': instance.isRead,
    };
