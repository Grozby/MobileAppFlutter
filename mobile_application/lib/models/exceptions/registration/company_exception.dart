import 'package:mobile_application/models/registration/registration_form.dart';

import 'registration_exception.dart';

class CompanyException extends RegistrationException{
  @override
  getMessage() => 'Incorrect company.';

  @override
  updateRegistrationForm(RegistrationForm registrationForm) {
    registrationForm.errorCompany = getMessage();
  }
}