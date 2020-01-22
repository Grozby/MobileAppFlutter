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
    questions: User.getQuestionFromJson(json['questions']),
    experiences: User.getExperiencesFromJson(json['pastExperiences']),
    socialAccounts: User.getSocialAccountsFromJson(json['socialAccounts']),
    currentJob:
        User.getCurrentJobFromJson(json['currentJob'] as Map<String, dynamic>),
    workingSpecialization:
        Mentor.getWorkingSpecializationFromJson(json['workingSpecialization']),
    questionsForAcceptingRequest:
        Mentor.getQuestionsForAcceptingRequestFromJson(
            json['questionsForAcceptingRequest']),
  )..id = json['_id'] as String;
}

Map<String, dynamic> _$MentorToJson(Mentor instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'surname': instance.surname,
      'pictureUrl': instance.pictureUrl,
      'location': instance.location,
      'bio': instance.bio,
      'currentJob': instance.currentJob?.toJson(),
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'pastExperiences': User.getJsonExperiences(instance.experiences),
      'socialAccounts': User.getJsonSocialAccounts(instance.socialAccounts),
      'workingSpecialization': instance.workingSpecialization,
      'questionsForAcceptingRequest': instance.questionsForAcceptingRequest
          ?.map((e) => e?.toJson())
          ?.toList(),
    };
