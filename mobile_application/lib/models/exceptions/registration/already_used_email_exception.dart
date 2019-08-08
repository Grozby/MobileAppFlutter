import 'package:mobile_application/models/registration/registration_form.dart';

import 'registration_exception.dart';

class AlreadyUsedEmailException extends RegistrationException{
  @override
  getMessage() => 'The email is already used.';

  @override
  updateRegistrationForm(RegistrationForm registrationForm) {
    registrationForm.errorEmail = getMessage();
  }
}