import 'dart:ui';

import '../../models/registration/sign_up_form_model.dart';

abstract class UserRegistration {
  String get registrationUrl;

  String get typeName;

  bool isMentor();

  Color get color;

  Map<String, String> getBodyRegistration(SignUpFormModel registrationForm);
}
