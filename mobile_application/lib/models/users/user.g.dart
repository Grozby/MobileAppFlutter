// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map json) {
  return User(
    id: json['_id'] as String,
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
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
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
    };
