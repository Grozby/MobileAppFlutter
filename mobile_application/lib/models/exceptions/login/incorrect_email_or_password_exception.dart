import '../../../models/login/login_form_model.dart';

import 'login_exception.dart';

class IncorrectEmailOrPasswordException extends LoginException {
  IncorrectEmailOrPasswordException() : super('Incorrect email or password.');

  @override
  updateLoginForm(LoginFormModel registrationForm) {
    registrationForm.errorEmail = getMessage();
    registrationForm.errorPassword = getMessage();
  }
}