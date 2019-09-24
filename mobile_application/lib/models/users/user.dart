import 'package:flutter/foundation.dart';

abstract class User {
  String name;
  String surname;
  String pictureUrl;
  String location;
  String bio;

  User({
    @required this.name,
    @required this.surname,
    @required this.pictureUrl,
    @required this.location,
    @required this.bio,
  });

  String get completeName => name + " " + surname;
}
