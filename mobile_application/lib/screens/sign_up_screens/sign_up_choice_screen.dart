import 'package:flutter/material.dart';


import '../../models/users/mentor.dart';
import '../../models/users/mentee.dart';
import '../../providers/theming/theme_provider.dart';
import '../../widgets/button_styled.dart';
import 'sign_up_screen.dart';

class SignUpChoiceScreen extends StatelessWidget {
  static const routeName = '/sign-up-choice';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: ThemeProvider.primaryColor,
        centerTitle: true,
        title: const Text('Sign Up'),
      ),
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
                  text: 'Mentor',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(
                      SignUpScreen.routeName,
                      arguments: Mentor(),
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
                      arguments: Mentee(),
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
                  onPressFunction: () {},
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
