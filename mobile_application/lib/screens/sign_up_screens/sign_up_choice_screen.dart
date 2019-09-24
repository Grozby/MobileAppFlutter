import 'package:flutter/material.dart';

import '../../models/registration/mentee_registration.dart';
import '../../models/registration/mentor_registration.dart';
import '../../providers/theming/theme_provider.dart';
import '../../widgets/back_button_customized.dart';
import '../../widgets/button_styled.dart';
import '../login_screen.dart';
import 'sign_up_screen.dart';

class SignUpChoiceScreen extends StatelessWidget {
  static const routeName = '/sign-up-choice';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: BackButtonCustomized(),
                  ),
                ),
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
                  text: 'Mentor',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(
                      SignUpScreen.routeName,
                      arguments: MentorRegistration(),
                    );
                  },
                  color: ThemeProvider.mentorColor,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Mentee',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(
                      SignUpScreen.routeName,
                      arguments: MenteeRegistration(),
                    );
                  },
                  color: ThemeProvider.menteeColor,
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login',
                  onPressFunction: () {
                    Navigator.of(context)
                        .pushReplacementNamed(LoginScreen.routeName);
                  },
                  color: Colors.grey.shade200,
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
