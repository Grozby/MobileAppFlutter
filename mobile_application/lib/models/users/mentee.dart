import 'dart:ui';

import '../../models/registration/registration_form.dart';
import '../../providers/configuration.dart';
import '../../providers/theming/theme_provider.dart';
import 'user.dart';

class Mentee extends User{
  @override
  String get name => 'Mentee';
  @override
  bool isMentor() => false;
  @override
  Color get color => ThemeProvider.menteeColor;

  @override
  @override
  String get registrationUrl => Configuration.serverUrl + Configuration.registrationPath + '/mentor';

  @override
  getBodyRegistration(RegistrationForm registrationForm) {
    return {
      'email': registrationForm.email,
      'password': registrationForm.password,
      'name': registrationForm.name,
      'surname': registrationForm.surname,
    };
  }
}