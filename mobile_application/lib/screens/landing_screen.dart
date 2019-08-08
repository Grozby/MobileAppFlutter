import 'package:flutter/material.dart';


import 'package:mobile_application/providers/theming/theme_provider.dart';
import '../widgets/button_styled.dart';
import 'sign_up_screens/sign_up_choice_screen.dart';

class LandingScreen extends StatelessWidget {
  static const routeName = '/landing';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ThemeProvider.primaryColor,
        title: const Text('Ryfy'),
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
                  text: 'Sign Up',
                  onPressFunction: () {
                    Navigator.of(context).pushNamed(SignUpChoiceScreen.routeName,);
                  },
                  color: ThemeProvider.primaryColor,
                ),
              ),
              Expanded(
                child: ButtonStyled(
                  dimensionButton: 10,
                  text: 'Login with Google',
                  onPressFunction: () {},
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
