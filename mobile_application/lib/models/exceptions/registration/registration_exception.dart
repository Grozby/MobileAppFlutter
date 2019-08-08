import '../../../models/registration/registration_form.dart';

abstract class RegistrationException implements Exception {
  getMessage();
  updateRegistrationForm(RegistrationForm registrationForm);
}