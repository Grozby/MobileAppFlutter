import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/exceptions/registration/already_used_email_exception.dart';
import '../../models/exceptions/registration/company_exception.dart';
import '../../models/exceptions/registration/email_exception.dart';
import '../../models/exceptions/registration/name_exception.dart';
import '../../models/exceptions/registration/password_exception.dart';
import '../../models/exceptions/registration/registration_exception.dart';
import '../../models/exceptions/registration/surname_exception.dart';

import '../../models/exceptions/login/login_exception.dart';
import '../../models/exceptions/login/incorrect_email_or_password_exception.dart';
import '../../models/registration/sign_up_form_model.dart';
import '../../models/users/user.dart';
import '../configuration.dart';

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class AuthenticationProvider with ChangeNotifier {
  String _token;
  String _user;
  Dio _httpManager;

  AuthenticationProvider() {
    // or new Dio with a Options instance.
    BaseOptions options = new BaseOptions(
      baseUrl: Configuration.serverUrl,
      connectTimeout: 7000,
      receiveTimeout: 3000,
    );
    _httpManager = new Dio(options);
    (_httpManager.transformer as DefaultTransformer).jsonDecodeCallback =
        parseJson;
  }

  /*----------
     Methods
   -----------*/

  bool gotAToken() => _token?.isNotEmpty ?? false;

  Future<void> loadAuthentication() async {
    //Load saved data, and check whether there is some token data stored.
    final storedData = await SharedPreferences.getInstance();
    //If we have some token, we proceed in storing it.
    if (storedData.containsKey('loginData')) {
      _token = storedData.getString('loginData');
    }
  }

  Map<String, String> get _authenticatedHeader {
    return {HttpHeaders.authorizationHeader: "Bearer " + _token};
  }

  Future<bool> checkAuthentication() async {
    if (!gotAToken()) {
      return false;
    }

    //If some data has been found, we proceed in make an authenticated request.
    //TODO
    return true;
  }

  ///
  /// Registration function that throws an RegistrationException if
  /// anything goes wrong.
  ///
  Future<void> registration(
      User userType, SignUpFormModel registrationForm) async {
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

  Future<void> authenticateWithCredentials(
      String email, String password) async {
    try {
      final response = await _httpManager.post(
        "/auth/login",
        data: {
          "username": email,
          "password": password,
          "grant_type": "password",
        },
        options: new Options(
          contentType: ContentType.parse("application/x-www-form-urlencoded"),
        ),
      );

      if (response.statusCode == 200) {
        _token = response.data["token_type"];
        notifyListeners();
        return;
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

  Future<String> loginWithGoogle() async {
    try {
      final response = await _httpManager.get(
        "/auth/google",
      );
      print(response);
    } on DioError catch (_) {
      throw LoginException(
        'Something went wrong. The internet connection seems to be down.',
      );
    }

    return Future.delayed(Duration(seconds: 2), () => "string");
  }

  String loginWithGoogleUrl() {
    return "https:www.google.com";
    //return "https://10.0.2.2:5001/auth/google";
  }
}
