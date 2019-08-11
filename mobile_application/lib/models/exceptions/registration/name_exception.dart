import 'package:mobile_application/models/registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class NameException extends RegistrationException {
  NameException() : super('Incorrect name.');

  @override
  updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorName = getMessage();
  }
}
