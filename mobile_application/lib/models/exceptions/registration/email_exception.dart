import 'package:mobile_application/models/registration/registration_form.dart';

import 'registration_exception.dart';

class EmailException extends RegistrationException{
  @override
  getMessage() => 'Incorrect email.';

  @override
  updateRegistrationForm(RegistrationForm registrationForm) {
    registrationForm.errorEmail = getMessage();
  }
}