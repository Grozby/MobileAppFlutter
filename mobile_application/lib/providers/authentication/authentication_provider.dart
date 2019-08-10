import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/registration/sign_up_form_model.dart';
import '../../models/exceptions/registration/already_used_email_exception.dart';
import '../../models/exceptions/registration/name_exception.dart';
import '../../models/exceptions/registration/surname_exception.dart';
import '../../models/exceptions/registration/email_exception.dart';
import '../../models/exceptions/registration/password_exception.dart';
import '../../models/exceptions/registration/company_exception.dart';
import '../../models/exceptions/registration/registration_exception.dart';
import '../../models/exceptions/login/incorrect_email_or_password_exception.dart';
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
      //TODO Throw error
    } on DioError catch (error) {
      if(error.type != DioErrorType.RESPONSE ){
        throw RegistrationException();
      }

      if (error.response.data.containsKey('error')) {
        switch (error.response.data['error']) {
          case 'EMAIL_ALREADY_USED':
            throw AlreadyUsedEmailException();
          default:
            throw RegistrationException();
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

      throw RegistrationException();
    }

    //Otherwise, we got an error. We proceed in checking what error is.
//    final responseData = json.decode(response.data);
//
//    if (responseData.containsKey('error')) {
//      switch (responseData['error']) {
//        case 'EMAIL_ALREADY_USED':
//          throw AlreadyUsedEmailException();
//        default:
//          throw RegistrationException();
//      }
//    }
//
//    if (responseData.containsKey('errors')) {
//      if ((responseData['errors'][0]).containsKey('param')) {
//        body.forEach((key, _) {
//          if (responseData['errors'][0]['param'] == key) {
//            throwErrorKey(key);
//          }
//        });
//      }
//
//      body.forEach((key, _) {
//        if (responseData['error'].containsKey(key)) {
//          throwErrorKey(key);
//        }
//      });
//    }
//
//    throw RegistrationException();
  }

  Future<void> authenticateWithCredentials(
      String email, String password) async {
    return Future.delayed(Duration(seconds: 2), () {
      throw IncorrectEmailOrPasswordException();
    });
  }
}
