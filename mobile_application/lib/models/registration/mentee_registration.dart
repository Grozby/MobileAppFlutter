import 'dart:ui';

import '../../providers/configuration.dart';
import '../../providers/theming/theme_provider.dart';
import '../registration/user_registration.dart';
import 'sign_up_form_model.dart';

class MenteeRegistration extends UserRegistration {
  @override
  String get typeName => 'Mentee';

  @override
  bool isMentor() => false;

  @override
  Color get color => ThemeProvider.menteeColor;

  @override
  String get registrationUrl => "${Configuration.registrationPath}/mentee";

  @override
  Map<String, String> getBodyRegistration(SignUpFormModel registrationForm) {
    return {
      'email': registrationForm.email.text,
      'password': registrationForm.password.text,
      'name': registrationForm.name.text,
      'surname': registrationForm.surname.text,
    };
  }
}
