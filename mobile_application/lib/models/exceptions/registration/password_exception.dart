import 'package:mobile_application/models/registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class PasswordException extends RegistrationException {
  PasswordException()
      : super('Incorrect password. Must be at least 8 characters.');

  @override
  updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorPassword = getMessage();
  }
}
