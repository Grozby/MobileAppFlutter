import 'package:flutter/material.dart';

class RegistrationForm {
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

  RegistrationForm() {
    name = TextEditingController();
    surname = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    company = TextEditingController();

    name.text = 'a';
    surname.text = 'a';
    email.text = "asdasadsds@google.c";
    password.text = 'aaaaaaaaaaaa';
    company.text = 'a';
  }
}