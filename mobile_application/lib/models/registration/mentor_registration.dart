import 'dart:ui';

import '../../models/registration/sign_up_form_model.dart';
import '../../providers/configuration.dart';
import '../../providers/theming/theme_provider.dart';
import '../registration/user_registration.dart';

class MentorRegistration extends UserRegistration {
  @override
  String get typeName => 'Mentor';

  @override
  bool isMentor() => true;

  @override
  Color get color => ThemeProvider.mentorColor;

  @override
  String get registrationUrl => "${Configuration.registrationPath}/mentor";

  @override
  Map<String, String> getBodyRegistration(SignUpFormModel registrationForm) {
    return {
      'email': registrationForm.email.text,
      'password': registrationForm.password.text,
      'name': registrationForm.name.text,
      'surname': registrationForm.surname.text,
      'referralCompany': registrationForm.company.text,
    };
  }
}
