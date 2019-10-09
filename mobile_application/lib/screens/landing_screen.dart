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
                    child: AnimatedCompanyNames(),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(),
              ),
              Expanded(
                child: ButtonStyled(
                  fractionalWidthDimension: 0.833,
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
                  fractionalWidthDimension: 0.833,
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
                  fractionalWidthDimension: 0.833,
                  text: 'Login with LinkedIn',
                  onPressFunction: () {},
                  color: Colors.blueAccent,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  fractionalWidthDimension: 0.833,
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

class AnimatedCompanyNames extends StatefulWidget {
  @override
  _AnimatedCompanyNamesState createState() => _AnimatedCompanyNamesState();
}

class _AnimatedCompanyNamesState extends State<AnimatedCompanyNames>
    with SingleTickerProviderStateMixin {
  final List<String> companyNames = [
    "Google",
    "Apple",
    "Amazon",
    "King",
    "Microsoft"
  ];

  AnimationController controller;
  Animation<Offset> slideInAnimation;
  Animation<double> fadeInAnimation;
  Animation<Offset> slideOutAnimation;
  Animation<double> fadeOutAnimation;
  int currentIndex;

  void restartAnimationAfter(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(Duration(seconds: 1), () {
        controller.reset();
        controller.forward();
        setState(() {
          currentIndex = (currentIndex + 1) % companyNames.length;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentIndex = 0;

    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    //Going in animations
    slideInAnimation = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
        .animate(controller)
          ..addStatusListener(restartAnimationAfter);

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

    //Going out animations
    slideOutAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0))
        .animate(controller);
    fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(controller);

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Meet your friend at",
          style: Theme.of(context).textTheme.title,
          textAlign: TextAlign.right,
        ),
        const SizedBox(width: 4),
        Container(
          width: 80,
          child: Stack(
            children: <Widget>[
              FadeTransition(
                opacity: fadeOutAnimation,
                child: SlideTransition(
                  position: slideOutAnimation,
                  child: Text(
                    companyNames[(currentIndex - 1) % companyNames.length],
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ),
              FadeTransition(
                opacity: fadeInAnimation,
                child: SlideTransition(
                  position: slideInAnimation,
                  child: Text(
                    companyNames[currentIndex],
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
