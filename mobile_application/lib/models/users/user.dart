import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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

///
///
/// USE 'flutter pub run build_runner watch' to update the Json serializer utility!!!
///
///
abstract class User {
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

  User({
    id,
    @required this.name,
    @required this.surname,
    @required this.pictureUrl,
    @required this.location,
    @required this.bio,
    @required this.questions,
    @required this.experiences,
    @required this.socialAccounts,
    @required this.currentJob,
  }) : id = id == null ? id = "0" : id;

  String get completeName => name + " " + surname;

  int get howManyQuestionsToAnswer;

  Color get color;

  Color get cardColor;

  List<Job> get jobExperiences =>
      experiences.where((e) => e is Job).map((j) => j as Job).toList();

  List<AcademicDegree> get academicExperiences => experiences
      .where((p) => p is AcademicDegree)
      .map((j) => j as AcademicDegree)
      .toList();

  ///
  /// Serializable methods
  ///
  static Job getCurrentJobFromJson(Map<String, dynamic> json) {
    return json != null ? Job.fromJson(json) : null;
  }

  static List<Question> getQuestionFromJson(questionsJson) {
    return questionsJson
            ?.map<Question>((q) => Question.fromJson(q))
            ?.toList() ??
        <Question>[];
  }

  static SocialAccount getSocialAccountFromJson(element) {
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
        })?.toList() ??
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
