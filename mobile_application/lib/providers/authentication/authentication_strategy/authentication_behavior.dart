abstract class AuthenticationBehavior {
  Future<void> authenticate(Map<String, String> data);
}