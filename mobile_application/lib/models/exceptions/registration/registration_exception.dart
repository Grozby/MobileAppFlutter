import '../../../models/registration/sign_up_form_model.dart';
import '../something_went_wrong_exception.dart';

class RegistrationException extends SomethingWentWrongException {
  RegistrationException(String t) : super.message(t);

  @override
  String getMessage() => text;

  void updateRegistrationForm(SignUpFormModel registrationForm) {}
}
