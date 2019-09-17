class SomethingWentWrongException implements Exception {
  final String text;

  SomethingWentWrongException() : text = "Something went wrong";

  SomethingWentWrongException.message(dynamic t)
      : text =
            (t != null && t.runtimeType == String) ? t : "Something went wrong";

  getMessage() => text;
}
