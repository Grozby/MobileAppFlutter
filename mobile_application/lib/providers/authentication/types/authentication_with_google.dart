import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    var response;

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
      response =  await authenticationProvider.httpRequestWrapper.request<bool>(
          url: authenticationUrl + (await account.authentication).idToken,
          correctStatusCode: 200,
          onCorrectStatusCode: (response) async {
            token = response.data["access_token"];
            await authenticationProvider.saveAuthenticationData();
            return true;
          },
          onIncorrectStatusCode: (_) {
            throw SomethingWentWrongException();
          }
      );

    } on PlatformException catch (e) {
      //Check if something went wrong with the GoogleSignIn plugin
      int errorCode = int.parse(e.message
          .substring(e.message.indexOf(':') + 2, e.message.lastIndexOf(':')));
      if (errorCode == 7) {
        throw SomethingWentWrongException.message(
            "Activate the internet connection to connect to RyFy.");
      }
      throw SomethingWentWrongException();
    } finally {
      if(overlay != null)
        overlay.remove();
    }

    return response;
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
