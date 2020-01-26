import '../../../models/login/login_form_model.dart';
import '../something_went_wrong_exception.dart';

class LoginException extends SomethingWentWrongException {
  LoginException(String t) : super.message(t);

  @override
  String getMessage() => text;

  void updateLoginForm(LoginFormModel registrationForm) {}
}
