import 'package:flutter/material.dart';

class LoginFormModel {
  TextEditingController email;
  String errorEmail;
  TextEditingController password;
  String errorPassword;

  LoginFormModel() {
    email = TextEditingController();
    password = TextEditingController();

    email.text = 'asdasadsds@google.com';
    password.text = 'pasadawd';
  }
}