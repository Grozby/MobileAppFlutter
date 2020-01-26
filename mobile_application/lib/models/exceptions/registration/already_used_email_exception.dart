import '../../registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class AlreadyUsedEmailException extends RegistrationException{
  AlreadyUsedEmailException() : super('The email is already used.');

  @override
  void updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorEmail = getMessage();
  }
}