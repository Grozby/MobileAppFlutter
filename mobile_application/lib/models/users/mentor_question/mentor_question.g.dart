// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MentorQuestion _$MentorQuestionFromJson(Map json) {
  return MentorQuestion(
    question: json['question'] as String,
    availableTime: json['availableTime'] as int,
  );
}

Map<String, dynamic> _$MentorQuestionToJson(MentorQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'availableTime': instance.availableTime,
    };
