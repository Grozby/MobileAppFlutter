import 'package:flutter/foundation.dart';
import '../../models/users/experiences/past_experience.dart';
import '../../models/users/question.dart';

abstract class User {
  String name;
  String surname;
  String pictureUrl;
  String location;
  String bio;
  List<Question> questions;
  List<PastExperience> pastExperiences;

  User({
    @required this.name,
    @required this.surname,
    @required this.pictureUrl,
    @required this.location,
    @required this.bio,
    @required this.questions,
    @required this.pastExperiences,
  })  : assert(name != null),
        assert(surname != null),
        assert(pictureUrl != null),
        assert(location != null),
        assert(bio != null),
        assert(questions != null),
        assert(pastExperiences != null);

  String get completeName => name + " " + surname;
}
