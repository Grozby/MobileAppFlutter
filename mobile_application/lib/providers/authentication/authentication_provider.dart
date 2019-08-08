import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/registration/registration_form.dart';
import '../../models/exceptions/registration/already_used_email_exception.dart';
import '../../models/exceptions/registration/name_exception.dart';
import '../../models/exceptions/registration/surname_exception.dart';
import '../../models/exceptions/registration/email_exception.dart';
import '../../models/exceptions/registration/password_exception.dart';
import '../../models/exceptions/registration/company_exception.dart';
import '../../models/exceptions/registration/registration_exception.dart';
import '../../models/users/user.dart';
import 'authentication_strategy/authentication_behavior.dart';

class AuthenticationProvider with ChangeNotifier {
  String _token;
  String _user;
  AuthenticationBehavior _authenticationBehavior;

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
  Future<bool> registration(
      User userType, RegistrationForm registrationForm) async {

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
    final response = await http.post(userType.registrationUrl,
        body: json.encode(body),
        headers: {
          'Content-type': 'application/json',
        });

    //If we have a 201, we are all set
    if (response.statusCode == 201) {
      return true;
    }

    //Otherwise, we got an error. We proceed in checking what error is.
    final responseData = json.decode(response.body);

    if(responseData.containsKey('error')){
      switch (responseData['error']) {
        case 'EMAIL_ALREADY_USED':
          return throw AlreadyUsedEmailException();
        default:
          return throw RegistrationException();
      }
    }

    if(responseData.containsKey('errors')){
      if((responseData['errors'][0]).containsKey('param')){
        body.forEach((key, _) {
          if(responseData['errors'][0]['param'] == key){
            throwErrorKey(key);
          }
        });
      }

      body.forEach((key, _) {
        if (responseData['error'].containsKey(key)) {
          throwErrorKey(key);
        }
      });
    }

    return throw RegistrationException();
  }

  Future<void> authenticate() async {}
}
