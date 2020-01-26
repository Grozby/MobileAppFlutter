class SomethingWentWrongException implements Exception {
  final String text;

  SomethingWentWrongException() : text = "Something went wrong";

  SomethingWentWrongException.message(dynamic t)
      : text = (t != null && t.runtimeType == String)
            ? t as String
            : "Something went wrong";

  String getMessage() => text;
}
