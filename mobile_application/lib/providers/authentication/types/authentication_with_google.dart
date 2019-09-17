import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../models/exceptions/login/login_exception.dart';
import '../../../models/exceptions/something_went_wrong_exception.dart';
import '../../../widgets/custom_alert_dialog.dart';
import 'authentication_mode.dart';

class AuthenticationWithGoogle extends AuthenticationMode {
  AuthenticationWithGoogle({
    @required httpManager,
    @required authenticationProvider,
  }) : super(
            httpManager: httpManager,
            authenticationProvider: authenticationProvider);

  AuthenticationWithGoogle.load({
    httpManager,
    authenticationProvider,
    token,
  }) : super.load(
          httpManager: httpManager,
          authenticationProvider: authenticationProvider,
          token: authenticationProvider,
        );

  @override
  Future<void> authenticate(data) async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      'profile',
      'email',
      'openid',
    ]);
    try {
      await googleSignIn.signOut();
      GoogleSignInAccount account = await googleSignIn.signIn();
      token = (await account.authentication).idToken;

      final response =
          await httpManager.get("/auth/google/signintoken?token=" + token);
      if (response.statusCode != 200) {
        throw SomethingWentWrongException();
      }
    } on PlatformException catch (e) {
      throw SomethingWentWrongException();
    } on DioError catch (error) {
      if (error.type != DioErrorType.RESPONSE) {
        throw LoginException(
          'Something went wrong. The internet connection seems to be down.',
        );
      } else {
        throw SomethingWentWrongException();
      }
    }
  }

  @override
  Future<bool> checkAuthentication() async {
    // TODO: implement checkAuthentication
    return token != null;
  }
}
