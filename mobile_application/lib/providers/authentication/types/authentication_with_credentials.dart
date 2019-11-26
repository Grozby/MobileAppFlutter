import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_application/helpers/http_request_wrapper.dart';

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
    return await authenticationProvider.httpRequestWrapper.request<bool>(
        url: "/auth/login",
        typeHttpRequest: TypeHttpRequest.post,
        postBody: {
          "username": data['email'],
          "password": data['password'],
          "grant_type": "password",
        },
        dioOptions: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        correctStatusCode: 200,
        onCorrectStatusCode: (response) async {
          token = response.data["access_token"];
          await authenticationProvider.saveAuthenticationData();
          return true;
        },
        onIncorrectStatusCode: (_) {
          throw LoginException(
            'Something went wrong. We couldn\'t validate the account. Try again later.',
          );
        },
        onUnknownDioError: (_) {
          throw IncorrectEmailOrPasswordException();
        });
  }

  @override
  String get nameAuthMode => "credentials";
}
