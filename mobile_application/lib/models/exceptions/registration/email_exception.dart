import 'package:mobile_application/models/registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class EmailException extends RegistrationException{
  @override
  getMessage() => 'Incorrect email.';

  @override
  updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorEmail = getMessage();
  }
}