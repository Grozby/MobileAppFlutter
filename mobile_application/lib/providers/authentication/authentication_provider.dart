import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  AuthenticationProvider(this._httpManager) {
    _authenticationMode = AuthenticationMode.getAuthenticationMode(
      'credentials',
      _httpManager,
      this,
    );
  }

  /*----------
     Methods
   -----------*/

  bool gotAToken() => _authenticationMode.gotAToken();

  Future<void> loadAuthentication() async {
    //Load saved data, and check whether there is some token data stored.
    final storedData = await SharedPreferences.getInstance();

    //If we have some saved data, we proceed in loading them.
    if (storedData.containsKey('loginData')) {
      var loginData = json.decode(storedData.getString('loginData'));

      _authenticationMode = AuthenticationMode.getAuthenticationMode(
        loginData.type,
        _httpManager,
        this,
      );
      _authenticationMode.token = loginData.authenticationToken;
    }
  }

  Future<void> saveAuthenticationData() async {
    final storedData = await SharedPreferences.getInstance();

    var loginData = {
      "type": _authenticationMode.nameAuthMode,
      "token": _authenticationMode.token,
    };

    await storedData.setString("loginData", json.encode(loginData));
  }

  Map<String, String> get _authenticatedHeader {
    return {
      HttpHeaders.authorizationHeader:
          "Bearer " + _authenticationMode.token
    };
  }

  Future<bool> checkAuthentication() async =>
      _authenticationMode.checkAuthentication();

  ///
  /// Registration function that throws an RegistrationException if
  /// anything goes wrong.
  ///
  Future<void> registration(
      UserRegistration userType, SignUpFormModel registrationForm) async {
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

    final body = userType.getBodyRegistration(registrationForm);

    try {
      final response =
          await _httpManager.post(userType.registrationUrl, data: body);
      //If we have a 201, we are all set
      if (response.statusCode == 201) {
        return;
      }
      //Otherwise we received something not expected. We throw an error.
      else {
        throw RegistrationException(
            'Something went wrong. We couldn\'t validate the response.');
      }
    } on DioError catch (error) {
      if (error.type != DioErrorType.RESPONSE) {
        throw RegistrationException(
          'Something went wrong. The internet connection seems to be down.',
        );
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
    }
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
    _authenticationMode = AuthenticationMode.getAuthenticationMode(
      'credentials',
      _httpManager,
      this,
    );
    notifyListeners();
  }
}
