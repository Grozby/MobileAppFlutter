import '../../../models/registration/sign_up_form_model.dart';
import '../something_went_wrong_exception.dart';

class RegistrationException extends SomethingWentWrongException {
  RegistrationException(String t) : super.message(t);


  @override
  getMessage() => text;

  updateRegistrationForm(SignUpFormModel registrationForm) {}

}
