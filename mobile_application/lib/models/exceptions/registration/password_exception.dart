import '../../../models/registration/sign_up_form_model.dart';
import 'registration_exception.dart';

class PasswordException extends RegistrationException {
  PasswordException()
      : super('Incorrect password. Must be at least 8 characters.');

  @override
  void updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorPassword = getMessage();
  }
}
