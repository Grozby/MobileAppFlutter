import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/http_request_wrapper.dart';
import '../../models/exceptions/registration/already_used_email_exception.dart';
import '../../models/exceptions/registration/company_exception.dart';
import '../../models/exceptions/registration/email_exception.dart';
import '../../models/exceptions/registration/name_exception.dart';
import '../../models/exceptions/registration/password_exception.dart';
import '../../models/exceptions/registration/registration_exception.dart';
import '../../models/exceptions/registration/surname_exception.dart';
import '../../models/registration/sign_up_form_model.dart';
import '../../models/registration/user_registration.dart';
import 'types/authentication_mode.dart';

class AuthenticationProvider with ChangeNotifier {
  AuthenticationMode _authenticationMode;
  final Dio _httpManager;
  HttpRequestWrapper httpRequestWrapper;
  bool wasLogged = false;

  AuthenticationProvider(this._httpManager) {
    _authenticationMode = AuthenticationMode.getAuthenticationMode(
      'credentials',
      _httpManager,
      this,
    );

    httpRequestWrapper = HttpRequestWrapper(httpManager: _httpManager);

    /// Adding interceptor to manage the authenticated requests.
    /// Every 401 error means we have some problems in the authentication.
    /// Therefore, every 401 causes the app to remove its authentication
    /// and rebuild.
    _httpManager.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          if (gotAToken()) {
            options.headers.putIfAbsent(
              HttpHeaders.authorizationHeader,
              () => "Bearer " + _authenticationMode.token,
            );
            return options;
          }
          return options;
        },
        onError: (DioError error) async {
          if (error.response?.statusCode == 401) {
            await removeAuthenticationData();
            //TODO
          }

          return error; //continue
        },
      ),
    );
  }

  /*----------
     Methods
   -----------*/

  bool gotAToken() => _authenticationMode.gotAToken();

  String get token => _authenticationMode.token;

  Future<void> loadAuthentication() async {
    //Load saved data, and check whether there is some token data stored.
    final storedData = await SharedPreferences.getInstance();

    //If we have some saved data, we proceed in loading them.
    if (storedData.containsKey('loginData')) {
      var loginData = json.decode(storedData.getString('loginData'));
      _authenticationMode = AuthenticationMode.getAuthenticationMode(
        loginData["type"],
        _httpManager,
        this,
      );
      _authenticationMode.token = loginData["token"];
      wasLogged = false;
    }
  }

  Future<void> saveAuthenticationData() async {
    final storedData = await SharedPreferences.getInstance();

    var loginData = {
      "type": _authenticationMode.nameAuthMode,
      "token": _authenticationMode.token,
    };

    await storedData.setString("loginData", json.encode(loginData));
    wasLogged = false;
  }

  Future<void> removeAuthenticationData() async {
    final storedData = await SharedPreferences.getInstance();

    if (storedData.containsKey("loginData")) {
      await storedData.remove("loginData");
      _authenticationMode =
          _authenticationMode = AuthenticationMode.getAuthenticationMode(
        'credentials',
        _httpManager,
        this,
      );
      wasLogged = true;
      notifyListeners();
    }
  }

  Future<bool> checkAuthentication() async {
    if (!gotAToken()) {
      return false;
    }

    final bool isLogged = await httpRequestWrapper.request<bool>(
      url: "/auth/checkauth",
      correctStatusCode: 200,
      onCorrectStatusCode: (_) async => true,
      onIncorrectStatusCode: (_) async => false,
    );

    if (!isLogged) {
      removeAuthenticationData();
    }

    return isLogged;
  }

  ///
  /// Registration function that throws an RegistrationException if
  /// anything goes wrong.
  ///
  Future<void> registration(
      UserRegistration userType, SignUpFormModel registrationForm) async {
    final body = userType.getBodyRegistration(registrationForm);

    return await httpRequestWrapper.request<void>(
      url: userType.registrationUrl,
      typeHttpRequest: TypeHttpRequest.post,
      postBody: body,
      correctStatusCode: 201,
      onCorrectStatusCode: (_) {},
      onIncorrectStatusCode: (_) {
        throw RegistrationException(
            'Something went wrong. We couldn\'t validate the response.');
      },
      onUnknownDioError: (error) {
        void throwErrorKey(String key) {
          switch (key) {
            case 'name':
              throw NameException();
            case 'surname':
              throw SurnameException();
            case 'email':
              throw EmailException();
            case 'password':
              throw PasswordException();
            case 'company':
              throw CompanyException();
          }
        }

        if (error.response.data.containsKey('error')) {
          switch (error.response.data['error']) {
            case 'EMAIL_ALREADY_USED':
              throw AlreadyUsedEmailException();
            default:
              throw RegistrationException(
                'Something went wrong. We couldn\'t validate the response.',
              );
          }
        }

        if (error.response.data.containsKey('errors')) {
          if ((error.response.data['errors'][0]).containsKey('param')) {
            body.forEach((key, _) {
              if (error.response.data['errors'][0]['param'] == key) {
                throwErrorKey(key);
              }
            });
          }

          body.forEach((key, _) {
            if (error.response.data['error'].containsKey(key)) {
              throwErrorKey(key);
            }
          });
        }

        throw RegistrationException(
          'Something went wrong. We couldn\'t validate the response.',
        );
      },
    );

  }

  Future<void> authenticate(dynamic data) async {
    bool isAuthenticated = await _authenticationMode.authenticate(data);

    if (isAuthenticated) {
      notifyListeners();
    }
  }

  Future<void> authenticateWithCredentials(
      String email, String password) async {
    _authenticationMode = AuthenticationMode.getAuthenticationMode(
      'credentials',
      _httpManager,
      this,
    );

    await authenticate({
      'email': email,
      'password': password,
    });
  }

  Future<void> authenticateWithGoogle(BuildContext context) async {
    _authenticationMode = AuthenticationMode.getAuthenticationMode(
      'google',
      _httpManager,
      this,
    );
    await authenticate(context);
  }

  Future<void> logout() async {
    await removeAuthenticationData();
    _authenticationMode = AuthenticationMode.getAuthenticationMode(
      'credentials',
      _httpManager,
      this,
    );
    notifyListeners();
  }
}
