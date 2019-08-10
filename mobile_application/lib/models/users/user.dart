import 'dart:ui';

import '../../models/registration/sign_up_form_model.dart';

abstract class User {
  String get registrationUrl;

  String get name;

  bool isMentor();

  Color get color;

  getBodyRegistration(SignUpFormModel registrationForm);
}
