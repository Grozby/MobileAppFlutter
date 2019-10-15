import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile_application/providers/authentication/authentication_provider.dart';

import 'authentication_with_credentials.dart';
import 'authentication_with_google.dart';

abstract class AuthenticationMode {
  String token;
  @protected
  Dio httpManager;
  @protected
  AuthenticationProvider authenticationProvider;

  static Map<String, Function> _constructorsMap = {
    'credentials':
        (Dio httpManager, AuthenticationProvider authenticationProvider) =>
            AuthenticationWithCredentials(
                httpManager: httpManager,
                authenticationProvider: authenticationProvider),
    'google':
        (Dio httpManager, AuthenticationProvider authenticationProvider) =>
            AuthenticationWithGoogle(
                httpManager: httpManager,
                authenticationProvider: authenticationProvider),
  };

  AuthenticationMode({
    @required this.httpManager,
    @required this.authenticationProvider,
  });

  AuthenticationMode.load({
    @required this.httpManager,
    @required this.authenticationProvider,
    @required this.token,
  });

  factory AuthenticationMode.getAuthenticationMode(
    String name,
    Dio httpManager,
    AuthenticationProvider authenticationProvider,
  ) {
    if (_constructorsMap.containsKey(name)) {
      return _constructorsMap[name](httpManager, authenticationProvider);
    } else {
      throw Exception();
    }
  }

  String get nameAuthMode;

  bool gotAToken() => token?.isNotEmpty ?? false;

  ///We return a boolean to decide whether we need to broadcast the notifyUpdates().
  Future<bool> authenticate(dynamic data);
}
