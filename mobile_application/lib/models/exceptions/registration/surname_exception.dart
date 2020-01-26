import '../../registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class SurnameException extends RegistrationException {
  SurnameException() : super('Incorrect surname.');

  @override
  void updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorSurname = getMessage();
  }
}
