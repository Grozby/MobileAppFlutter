import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../models/users/experiences/academic_degree.dart';
import '../../models/users/experiences/job.dart';
import '../../models/users/experiences/past_experience.dart';
import '../../models/users/question.dart';
import '../../models/users/socials/facebook_account.dart';
import '../../models/users/socials/github_account.dart';
import '../../models/users/socials/instagram_account.dart';
import '../../models/users/socials/linkedin_account.dart';
import '../../models/users/socials/social_account.dart';
import '../../models/users/socials/twitter_account.dart';

part 'user.g.dart';

///
///
/// USE 'flutter pub run build_runner watch' to update the Json serializer utility!!!
///
///

@JsonSerializable(explicitToJson: true)
class User {
  @JsonKey(name: "_id")
  String id;
  String name;
  String surname;
  String pictureUrl;
  String location;
  String bio;

  @JsonKey(fromJson: getCurrentJobFromJson)
  Job currentJob;

  @JsonKey(fromJson: getQuestionFromJson, nullable: false)
  List<Question> questions;

  @JsonKey(
    name: "pastExperiences",
    fromJson: getExperiencesFromJson,
    toJson: getJsonExperiences,
  )
  List<PastExperience> experiences;

  @JsonKey(
    fromJson: getSocialAccountsFromJson,
    toJson: getJsonSocialAccounts,
  )
  HashMap<String, SocialAccount> socialAccounts;

  @JsonKey(
    fromJson: getWorkingSpecializationFromJson,
  )
  List<String> workingSpecialization;

  User({
    String id,
    @required this.name,
    @required this.surname,
    @required this.pictureUrl,
    @required this.location,
    @required this.bio,
    @required this.questions,
    @required this.experiences,
    @required this.socialAccounts,
    @required this.currentJob,
    @required this.workingSpecialization,
  }) : id = id == null ? id = "0" : id;

  String get completeName => "$name $surname";

  int get howManyQuestionsToAnswer => 0;

  Color get color => Colors.blueGrey;

  Color get cardColor => Colors.grey;

  List<Job> get jobExperiences => experiences.whereType<Job>().toList();

  List<AcademicDegree> get academicExperiences =>
      experiences.whereType<AcademicDegree>().toList();

  ///
  /// Serializable methods
  ///

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  static Job getCurrentJobFromJson(Map<String, dynamic> json) {
    return json != null ? Job.fromJson(json) : null;
  }

  static List<Question> getQuestionFromJson(questionsJson) {
    return questionsJson?.map<Question>((q) => Question.fromJson(q))?.toList()
            as List<Question> ??
        <Question>[];
  }

  static SocialAccount getSocialAccountFromJson(Map<String, String> element) {
    switch (element["type"]) {
      case "twitter":
        return TwitterAccount.fromJson(element);
      case "facebook":
        return FacebookAccount.fromJson(element);
      case "github":
        return GithubAccount.fromJson(element);
      case "linkedin":
        return LinkedInAccount.fromJson(element);
      case "instagram":
        return InstagramAccount.fromJson(element);
      default:
        throw Exception();
    }
  }

  static HashMap<String, SocialAccount> getSocialAccountsFromJson(
    socialAccountsJson,
  ) {
    HashMap<String, SocialAccount> hashMap = HashMap();

    socialAccountsJson
        ?.forEach((e) => hashMap[e["type"]] = getSocialAccountFromJson(e));

    return hashMap;
  }

  static List<Map<String, dynamic>> getJsonSocialAccounts(
      HashMap<String, SocialAccount> socialAccount) {
    List<Map<String, dynamic>> list = List();

    socialAccount?.forEach((key, socialAccount) {
      var map = socialAccount.toJson();
      map["type"] = socialAccount.typeAccount;
      list.add(map);
    });

    return list;
  }

  static List<PastExperience> getExperiencesFromJson(experiencesJson) {
    return experiencesJson?.map<PastExperience>((e) {
          switch (e["kind"]) {
            case "Job": // Selector decided by the backend
              return Job.fromJson(e);
            case "Education":
              return AcademicDegree.fromJson(e);
            default:
              throw Exception();
          }
        })?.toList() as List<PastExperience> ??
        <PastExperience>[];
  }

  static List<Map<String, dynamic>> getJsonExperiences(
      List<PastExperience> experiences) {
    return experiences?.map<Map<String, dynamic>>((e) {
      if (e is Job) {
        var map = e.toJson();
        map["type"] = "OldJob";
        return map;
      }
      if (e is AcademicDegree) {
        var map = e.toJson();
        map["type"] = "AcademicDegree";
        return map;
      }

      throw Exception("Not a past experience!!");
    })?.toList();
  }

  static List<String> getWorkingSpecializationFromJson(dynamic json) {
    return json?.map<String>((e) => e as String)?.toList() as List<String> ??
        <String>[];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          surname == other.surname;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      surname.hashCode ^
      pictureUrl.hashCode ^
      location.hashCode ^
      bio.hashCode ^
      currentJob.hashCode ^
      questions.hashCode ^
      experiences.hashCode ^
      socialAccounts.hashCode;
}
