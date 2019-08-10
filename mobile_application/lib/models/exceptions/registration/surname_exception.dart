import 'package:mobile_application/models/registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class SurnameException extends RegistrationException{
  @override
  getMessage() => 'Incorrect surname.';

  @override
  updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorSurname = getMessage();
  }
}