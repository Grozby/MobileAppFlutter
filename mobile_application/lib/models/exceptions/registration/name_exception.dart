import 'package:mobile_application/models/registration/registration_form.dart';

import 'registration_exception.dart';

class NameException extends RegistrationException{
  @override
  getMessage() => 'Incorrect name.';

  @override
  updateRegistrationForm(RegistrationForm registrationForm) {
    registrationForm.errorName = getMessage();
  }
}