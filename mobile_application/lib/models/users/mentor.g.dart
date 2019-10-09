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
    pastExperiences: User.getExperiences(json['pastExperiences']),
    company: json['company'] as String,
    jobType: json['jobType'] as String,
    workingSpecialization: (json['workingSpecialization'] as List)
        ?.map((e) => e as String)
        ?.toList(),
    companyImageUrl: json['companyImageUrl'] as String,
  );
}

Map<String, dynamic> _$MentorToJson(Mentor instance) => <String, dynamic>{
      'name': instance.name,
      'surname': instance.surname,
      'pictureUrl': instance.pictureUrl,
      'location': instance.location,
      'bio': instance.bio,
      'questions': instance.questions?.map((e) => e?.toJson())?.toList(),
      'pastExperiences': User.getJsonExperiences(instance.pastExperiences),
      'company': instance.company,
      'jobType': instance.jobType,
      'workingSpecialization': instance.workingSpecialization,
      'companyImageUrl': instance.companyImageUrl,
    };
