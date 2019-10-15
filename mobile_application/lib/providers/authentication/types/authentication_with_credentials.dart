import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../helpers/utilities.dart';
import '../../../models/exceptions/login/incorrect_email_or_password_exception.dart';
import '../../../models/exceptions/login/login_exception.dart';
import '../../../models/exceptions/no_internet_exception.dart';
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
        await authenticationProvider.saveAuthenticationData();
        return true;
      } else {
        throw LoginException(
          'Something went wrong. We couldn\'t validate the account. Try again later.',
        );
      }
    } on DioError catch (error) {
      if (error.type != DioErrorType.RESPONSE) {
        throw NoInternetException(getWhatConnectionError(error));
      } else {
        throw IncorrectEmailOrPasswordException();
      }
    }
  }

  @override
  String get nameAuthMode => "credentials";
}
