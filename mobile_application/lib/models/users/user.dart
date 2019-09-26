import 'package:flutter/foundation.dart';

abstract class User {
  String name;
  String surname;
  String pictureUrl;
  String location;
  String bio;
  List<String> favoriteLanguages;

  User({
    @required this.name,
    @required this.surname,
    @required this.pictureUrl,
    @required this.location,
    @required this.bio,
    @required this.favoriteLanguages,
  });

  String get completeName => name + " " + surname;

  String get favoriteLanguagesString => favoriteLanguages.join(", ");
}
