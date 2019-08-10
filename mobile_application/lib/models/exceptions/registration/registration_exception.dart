import '../../../models/registration/sign_up_form_model.dart';
import '../something_went_wrong_exception.dart';

class RegistrationException extends SomethingWentWrongException {
  @override
  getMessage() => "RegistrationException";

  updateRegistrationForm(SignUpFormModel registrationForm) {}
}
