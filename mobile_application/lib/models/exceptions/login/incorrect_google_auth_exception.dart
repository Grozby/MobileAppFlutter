import '../something_went_wrong_exception.dart';

class IncorrectGoogleAuthException extends SomethingWentWrongException {
  IncorrectGoogleAuthException()
      : super.message('There are some problems with Google\'s authentication.');
}
