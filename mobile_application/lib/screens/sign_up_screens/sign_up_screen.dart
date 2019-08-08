import 'package:flutter/material.dart';

import '../../models/users/user.dart';
import '../../widgets/button_styled.dart';
import '../login_screen.dart';
import '../../widgets/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  static const routeName = '/sign-up';

  @override
  Widget build(BuildContext context) {
    final userType = ModalRoute.of(context).settings.arguments as User;
    final mediaQuery = MediaQuery.of(context);
    final scrollController = ScrollController();
    final appBar = AppBar(
      backgroundColor: userType.color,
      centerTitle: true,
      title: const Text('Sign Up'),
    );
    final heightScreen = (mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top);

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Container(
          height: (heightScreen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                child: Container(),
              ),
              Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Sign up as a ${userType.name}',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                flex: 8,
                child: SignUpForm(
                  userType: userType,
                  scrollController: scrollController,
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        LoginScreen.routeName,
                        ModalRoute.withName(Navigator.defaultRouteName),
                      );
                    },
                    child: Text(
                      'Already have an account? Log in',
                    ),
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
