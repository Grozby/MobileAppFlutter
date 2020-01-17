import 'something_went_wrong_exception.dart';

class NoUserProfileException extends SomethingWentWrongException {
  NoUserProfileException() : super();

  @override
  getMessage() => "Oops. Couldn't retrive the user!";
}
