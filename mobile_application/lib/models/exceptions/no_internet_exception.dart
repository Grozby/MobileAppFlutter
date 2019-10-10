import 'something_went_wrong_exception.dart';

class NoInternetException extends SomethingWentWrongException {
  NoInternetException(String t) : super.message(t);

  @override
  getMessage() => text;
}
