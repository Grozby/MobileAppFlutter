// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map json) {
  return Answer(
    question: json['question'] as String,
    textAnswer: json['textAnswer'] as String,
    audioAnswer: json['audioAnswer'] as String,
  );
}

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'question': instance.question,
      'textAnswer': instance.textAnswer,
      'audioAnswer': instance.audioAnswer,
    };
