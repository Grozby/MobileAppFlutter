// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mentee _$MenteeFromJson(Map json) {
  return Mentee(
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
    tokenWallet: json['tokenWallet'] as int,
  );
}

Map<String, dynamic> _$MenteeToJson(Mentee instance) => <String, dynamic>{
      'name': instance.name,
      'surname': instance.surname,
      'pictureUrl': instance.pictureUrl,
      'location': instance.location,
      'bio': instance.bio,
      'currentJob': instance.currentJob?.toJson(),
      'questions': instance.questions?.map((e) => e?.toJson())?.toList(),
      'pastExperiences': User.getJsonExperiences(instance.experiences),
      'socialAccounts': User.getJsonSocialAccounts(instance.socialAccounts),
      'tokenWallet': instance.tokenWallet,
    };
