import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/experiences/academic_degree.dart';
import 'package:mobile_application/models/users/experiences/job.dart';
import 'package:mobile_application/models/users/socials/facebook_account.dart';
import 'package:mobile_application/models/users/socials/github_account.dart';
import 'package:mobile_application/models/users/socials/instagram_account.dart';
import 'package:mobile_application/models/users/socials/linkedin_account.dart';
import 'package:mobile_application/models/users/socials/social_account.dart';
import 'package:mobile_application/models/users/socials/twitter_account.dart';
import '../../models/users/experiences/past_experience.dart';
import '../../models/users/question.dart';
import 'package:json_annotation/json_annotation.dart';

///
///
/// USE 'flutter pub run build_runner watch' to update the Json serializer utility!!!
///
///
abstract class User {
  String name;
  String surname;
  String pictureUrl;
  String location;
  String bio;
  Job currentJob;
  @JsonKey(fromJson: getQuestion)
  List<Question> questions;
  @JsonKey(
    name: "pastExperiences",
    fromJson: getExperiences,
    toJson: getJsonExperiences,
  )
  List<PastExperience> experiences;

  @JsonKey(
    fromJson: getSocialAccounts,
    toJson: getJsonSocialAccounts,
  )
  HashMap<String, SocialAccount> socialAccounts;

  User({
    @required this.name,
    @required this.surname,
    @required this.pictureUrl,
    @required this.location,
    @required this.bio,
    @required this.questions,
    @required this.experiences,
    @required this.socialAccounts,
    @required this.currentJob,
  })  : assert(name != null),
        assert(surname != null),
        assert(pictureUrl != null),
        assert(location != null),
        assert(bio != null),
        assert(questions != null),
        assert(experiences != null),
        assert(socialAccounts != null),
        assert(currentJob != null);

  String get completeName => name + " " + surname;

  Color get color;

  Color get cardColor;

  List<Job> get jobExperiences =>
      experiences.where((e) => e is Job).map((j) => j as Job).toList();

  List<AcademicDegree> get academicExperiences => experiences
      .where((p) => p is AcademicDegree)
      .map((j) => j as AcademicDegree)
      .toList();

  static List<Question> getQuestion(questionsJson) {
    return questionsJson.map<Question>((q) => Question.fromJson(q)).toList();
  }

  static SocialAccount getSocialAccount(element) {
    switch (element["type"]) {
      case "Twitter":
        return TwitterAccount.fromJson(element["content"]);
      case "Facebook":
        return FacebookAccount.fromJson(element["content"]);
      case "Github":
        return GithubAccount.fromJson(element["content"]);
      case "Linkedin":
        return LinkedInAccount.fromJson(element["content"]);
      case "Instagram":
        return InstagramAccount.fromJson(element["content"]);
      default:
        throw Exception();
    }
  }

  static HashMap<String, SocialAccount> getSocialAccounts(socialAccountsJson) {
    HashMap<String, SocialAccount> hashMap = HashMap();
    socialAccountsJson.forEach((e) => hashMap[e["type"]] = getSocialAccount(e));
    return hashMap;
  }

  static List<Map<String, dynamic>> getJsonSocialAccounts(
      HashMap<String, SocialAccount> socialAccount) {
    List<Map<String, dynamic>> list = List();

    socialAccount.forEach((key, socialAccount) {
      var map = socialAccount.toJson();
      map["type"] = socialAccount.typeAccount;
      list.add(map);
    });

    return list;
  }

  static List<PastExperience> getExperiences(experiencesJson) {
    return experiencesJson.map<PastExperience>((e) {
      switch (e["kind"]) {
        case "Job": // Selector decided by the backend
          return Job.fromJson(e);
        case "Education":
          return AcademicDegree.fromJson(e);
        default:
          throw Exception();
      }
    }).toList();
  }

  static List<Map<String, dynamic>> getJsonExperiences(
      List<PastExperience> experiences) {
    return experiences.map<Map<String, dynamic>>((e) {
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
    }).toList();
  }

  Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
        'question': instance.question,
        'answer': instance.answer,
      };
}
