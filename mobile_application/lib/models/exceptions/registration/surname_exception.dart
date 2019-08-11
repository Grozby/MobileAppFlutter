import 'package:mobile_application/models/registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class SurnameException extends RegistrationException {
  SurnameException() : super('Incorrect surname.');

  @override
  updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorSurname = getMessage();
  }
}
