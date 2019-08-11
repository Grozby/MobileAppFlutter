import 'package:mobile_application/models/registration/sign_up_form_model.dart';

import 'registration_exception.dart';

class CompanyException extends RegistrationException {
  CompanyException() : super('Incorrect company.');

  @override
  updateRegistrationForm(SignUpFormModel registrationForm) {
    registrationForm.errorCompany = getMessage();
  }
}
