import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../helpers/utilities.dart';
import '../../../models/exceptions/no_internet_exception.dart';
import '../../../models/exceptions/something_went_wrong_exception.dart';
import 'authentication_mode.dart';

class AuthenticationWithGoogle extends AuthenticationMode {
  final String authenticationUrl = "/auth/google/signintoken?token=";

  AuthenticationWithGoogle({
    @required httpManager,
    @required authenticationProvider,
  }) : super(
            httpManager: httpManager,
            authenticationProvider: authenticationProvider);

  AuthenticationWithGoogle.load({
    httpManager,
    authenticationProvider,
    authenticationToken,
  }) : super.load(
          httpManager: httpManager,
          authenticationProvider: authenticationProvider,
          token: authenticationToken,
        );

  ///The function authenticate accepts a BuildContext, used for aesthetic reasons.
  @override
  Future<bool> authenticate(data) async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      'profile',
      'email',
      'openid',
    ]);

    var overlay;

    try {
      await googleSignIn.signOut();
      GoogleSignInAccount account = await googleSignIn.signIn();

      if (account == null) {
        return false;
      }

      //We add an overlay for aesthetic reasons.
      overlay = _createOverlay(data);
      Overlay.of(data).insert(overlay);

      //Then, we check with the backend the obtained token.
      final response = await httpManager
          .get(authenticationUrl + (await account.authentication).idToken);

      //We check whether the request went smoothly or not.
      if (response.statusCode != 200) {
        throw SomethingWentWrongException();
      } else {
        token = response.data["access_token"];
        authenticationProvider.saveAuthenticationData();
        return true;
      }
    } on PlatformException catch (e) {
      //Check if something went wrong with the GoogleSignIn plugin
      int errorCode = int.parse(e.message
          .substring(e.message.indexOf(':') + 2, e.message.lastIndexOf(':')));
      if (errorCode == 7) {
        throw SomethingWentWrongException.message(
            "Activate the internet connection to connect to RyFy.");
      }
      throw SomethingWentWrongException();
    } on DioError catch (error) {
      //Check if something went wrong with the http request
      if (error.type != DioErrorType.RESPONSE) {
        throw NoInternetException(getWhatConnectionError(error));
      } else {
        throw SomethingWentWrongException.message(
            "Couldn't validate the Google account. Try again later.");
      }
    } finally {
      overlay.remove();
    }
  }

  OverlayEntry _createOverlay(BuildContext context) {
    double _value = 10;
    return OverlayEntry(
      builder: (context) => new Stack(
        children: <Widget>[
          new BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _value, sigmaY: _value),
            child: Container(
              color: Colors.black26,
            ),
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  @override
  String get nameAuthMode => "google";
}
