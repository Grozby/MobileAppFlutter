import 'something_went_wrong_exception.dart';

class NoUserProfileException extends SomethingWentWrongException {
  NoUserProfileException() : super();

  @override
  String getMessage() => "Oops. Couldn't retrive the user!";
}
