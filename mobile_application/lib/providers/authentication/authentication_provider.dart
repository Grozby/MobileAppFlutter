import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/registration/registration_form.dart';
import '../../models/exceptions/registration/already_used_email_exception.dart';
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

  Future<bool> registration (
      User userType, RegistrationForm registrationForm) async {
    final response = await http.post(
      userType.registrationUrl,
      body: json.encode(userType.getBodyRegistration(registrationForm)),
    );

    print('dajeeeeeee');
    final responseData = json.decode(response.body);
    if (responseData['error'] != null) {
      switch (responseData['error']) {
        case 'EMAIL_ALREADY_USED':
          return throw AlreadyUsedEmailException();
        default:
          return throw RegistrationException();
      }
    }


    return Future<bool>.delayed(
        Duration(seconds: 1), () => throw AlreadyUsedEmailException());
  }

  Future<void> authenticate() async {}
}
