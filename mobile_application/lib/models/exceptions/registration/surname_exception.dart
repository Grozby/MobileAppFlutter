import 'package:mobile_application/models/registration/registration_form.dart';

import 'registration_exception.dart';

class SurnameException extends RegistrationException{
  @override
  getMessage() => 'Incorrect surname.';

  @override
  updateRegistrationForm(RegistrationForm registrationForm) {
    registrationForm.errorSurname = getMessage();
  }
}