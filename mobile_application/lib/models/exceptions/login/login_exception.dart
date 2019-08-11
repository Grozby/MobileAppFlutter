import '../../../models/login/login_form_model.dart';
import '../something_went_wrong_exception.dart';

class LoginException extends SomethingWentWrongException {
  String text;

  LoginException(this.text);

  @override
  getMessage() => text;

  updateLoginForm(LoginFormModel registrationForm) {}
}
