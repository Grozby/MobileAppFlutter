import '../../../models/registration/sign_up_form_model.dart';
import '../something_went_wrong_exception.dart';

class RegistrationException extends SomethingWentWrongException {
  final String text;
  RegistrationException(this.text);

  @override
  getMessage() => text;

  updateRegistrationForm(SignUpFormModel registrationForm) {}

}
