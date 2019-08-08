import 'dart:ui';

import '../../models/registration/registration_form.dart';

abstract class User {
  String get registrationUrl;

  String get name;

  bool isMentor();

  Color get color;

  getBodyRegistration(RegistrationForm registrationForm);
}
