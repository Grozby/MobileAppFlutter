import 'dart:ui';

import 'package:mobile_application/models/registration/registration_form.dart';

import '../../providers/theming/theme_provider.dart';
import '../../providers/configuration.dart';
import 'user.dart';

class Mentor extends User {
  @override
  String get name => 'Mentor';

  @override
  bool isMentor() => true;

  @override
  Color get color => ThemeProvider.mentorColor;

  @override
  String get registrationUrl =>
      Configuration.serverUrl + Configuration.registrationPath + '/mentor';

  @override
  getBodyRegistration(RegistrationForm registrationForm) {
    return {
      'email': registrationForm.email,
      'password': registrationForm.password,
      'name': registrationForm.name,
      'surname': registrationForm.surname,
      'company': registrationForm.company,
    };
  }
}
