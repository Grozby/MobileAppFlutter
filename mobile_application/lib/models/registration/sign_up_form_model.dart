import 'package:flutter/material.dart';

class SignUpFormModel {
  TextEditingController name;
  String errorName;
  TextEditingController surname;
  String errorSurname;
  TextEditingController email;
  String errorEmail;
  TextEditingController password;
  String errorPassword;
  TextEditingController company;
  String errorCompany;

  SignUpFormModel() {
    name = TextEditingController();
    surname = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    company = TextEditingController();
  }
}