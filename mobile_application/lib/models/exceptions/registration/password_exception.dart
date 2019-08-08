import 'package:mobile_application/models/registration/registration_form.dart';

import 'registration_exception.dart';

class PasswordException extends RegistrationException{
  @override
  getMessage() => 'Incorrect password. Must be at least 8 characters.';

  @override
  updateRegistrationForm(RegistrationForm registrationForm) {
    registrationForm.errorPassword = getMessage();
  }
}