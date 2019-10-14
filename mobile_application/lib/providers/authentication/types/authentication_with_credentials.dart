import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_application/models/exceptions/something_went_wrong_exception.dart';

import '../../../models/exceptions/login/incorrect_email_or_password_exception.dart';
import '../../../models/exceptions/login/login_exception.dart';
import '../../../providers/authentication/types/authentication_mode.dart';

class AuthenticationWithCredentials extends AuthenticationMode {
  AuthenticationWithCredentials({
    @required httpManager,
    @required authenticationProvider,
  }) : super(
            httpManager: httpManager,
            authenticationProvider: authenticationProvider);

  @override
  Future<bool> authenticate(dynamic data) async {
    try {
      final response = await httpManager.post(
        "/auth/login",
        data: {
          "username": data['email'],
          "password": data['password'],
          "grant_type": "password",
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        token = response.data["access_token"];
        authenticationProvider.saveAuthenticationData();
        return true;
      } else {
        throw LoginException(
          'Something went wrong. We couldn\'t validate the account. Try again later.',
        );
      }
    } on DioError catch (error) {
      if (error.type != DioErrorType.RESPONSE) {
        throw LoginException(
          'Something went wrong. The internet connection seems to be down.',
        );
      } else {
        throw IncorrectEmailOrPasswordException();
      }
    }
  }

  ///When we register with email and password we already know if the user is
  ///a mentor or mentee.
  @override
  Future<bool> checkAuthentication() async {
    if (!gotAToken()) {
      return false;
    }

    //If some data has been found, we proceed in make an authenticated request.
    try {
      final response = await httpManager.get("/checkauth");

      if (response.statusCode != 200) {
        return true;
      } else {
        return false;
      }
    } on DioError catch (_) {
      ///SHOULD NOT FALL IN THERE
      return false;
    }
  }

  @override
  String get nameAuthMode => "credentials";
}
