import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authentication/authentication_provider.dart';
import '../providers/theming/theme_provider.dart';
import '../widgets/button_styled.dart';
import '../widgets/custom_alert_dialog.dart';
import './../models/exceptions/something_went_wrong_exception.dart';
import 'login_screen.dart';
import 'sign_up_screens/sign_up_choice_screen.dart';

class LandingScreen extends StatefulWidget {
  static const routeName = '/landing';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  AuthenticationProvider _authenticationProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _authenticationProvider =
          Provider.of<AuthenticationProvider>(context, listen: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Meet your friend at COMPANY',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Sign Up',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(
                      SignUpChoiceScreen.routeName,
                    );
                  },
                  color: ThemeProvider.primaryColor,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login with Google',
                  onPressFunction: () async {
                    try {
                      await _authenticationProvider
                          .authenticateWithGoogle(context);
                      print("");
                    } on SomethingWentWrongException catch (e) {
                      showErrorDialog(context, e.getMessage());
                    }
                  },
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login with LinkedIn',
                  onPressFunction: () {},
                  color: Colors.blueAccent,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(
                      LoginScreen.routeName,
                    );
                  },
                  color: ThemeProvider.loginButtonColor,
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
