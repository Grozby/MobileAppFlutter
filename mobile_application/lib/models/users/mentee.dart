import 'dart:ui';

import '../../models/registration/sign_up_form_model.dart';
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
  String get registrationUrl => Configuration.serverUrl + Configuration.registrationPath + '/mentor';

  @override
  getBodyRegistration(SignUpFormModel registrationForm) {
    return {
      'email': registrationForm.email.text,
      'password': registrationForm.password.text,
      'name': registrationForm.name.text,
      'surname': registrationForm.surname.text,
    };
  }
}