import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/users/experiences/past_experience.dart';

abstract class User {
  String name;
  String surname;
  String pictureUrl;
  String location;
  String bio;
  List<String> favoriteLanguages;
  List<PastExperience> academicDegrees;

  User({
    @required this.name,
    @required this.surname,
    @required this.pictureUrl,
    @required this.location,
    @required this.bio,
    @required this.favoriteLanguages,
    @required this.academicDegrees,
  });

  String get completeName => name + " " + surname;

  String get favoriteLanguagesString => favoriteLanguages.join(", ");
}
