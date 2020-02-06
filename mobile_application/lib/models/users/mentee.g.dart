// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mentee _$MenteeFromJson(Map json) {
  return Mentee(
    name: json['name'] as String,
    surname: json['surname'] as String,
    pictureUrl: json['pictureUrl'] as String,
    location: json['location'] as String,
    bio: json['bio'] as String,
    questions: User.getQuestionFromJson(json['questions']),
    experiences: User.getExperiencesFromJson(json['pastExperiences']),
    socialAccounts: User.getSocialAccountsFromJson(json['socialAccounts']),
    currentJob:
        User.getCurrentJobFromJson(json['currentJob'] as Map<String, dynamic>),
    tokenWallet: json['tokenWallet'] as int,
  )
    ..id = json['_id'] as String
    ..workingSpecialization =
        User.getWorkingSpecializationFromJson(json['workingSpecialization']);
}

Map<String, dynamic> _$MenteeToJson(Mentee instance) => <String, dynamic>{
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
      'tokenWallet': instance.tokenWallet,
    };
