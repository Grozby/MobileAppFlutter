// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mentor _$MentorFromJson(Map json) {
  return Mentor(
    name: json['name'],
    surname: json['surname'],
    pictureUrl: json['pictureUrl'],
    location: json['location'],
    bio: json['bio'],
    questions: User.getQuestion(json['questions']),
    experiences: User.getExperiences(json['pastExperiences']),
    socialAccounts: User.getSocialAccounts(json['socialAccounts']),
    currentJob: json['currentJob'],
    workingSpecialization: (json['workingSpecialization'] as List)
        ?.map((e) => e as String)
        ?.toList(),
    questionsForAcceptingRequest: (json['questionsForAcceptingRequest'] as List)
        ?.map((e) => e == null ? null : MentorQuestion.fromJson(e as Map))
        ?.toList(),
  );
}

Map<String, dynamic> _$MentorToJson(Mentor instance) => <String, dynamic>{
      'name': instance.name,
      'surname': instance.surname,
      'pictureUrl': instance.pictureUrl,
      'location': instance.location,
      'bio': instance.bio,
      'currentJob': instance.currentJob?.toJson(),
      'questions': instance.questions?.map((e) => e?.toJson())?.toList(),
      'pastExperiences': User.getJsonExperiences(instance.experiences),
      'socialAccounts': User.getJsonSocialAccounts(instance.socialAccounts),
      'workingSpecialization': instance.workingSpecialization,
      'questionsForAcceptingRequest': instance.questionsForAcceptingRequest
          ?.map((e) => e?.toJson())
          ?.toList(),
    };
