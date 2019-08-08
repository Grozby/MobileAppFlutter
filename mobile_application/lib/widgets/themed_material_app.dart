import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_application/providers/theming/theme_provider.dart';
import '../providers/authentication/authentication_provider.dart';
import '../screens/waiting_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/homepage_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sign_up_screens/sign_up_choice_screen.dart';
import '../screens/sign_up_screens/sign_up_screen.dart';

class ThemedMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);

    return MaterialApp(
      theme: currentTheme.getTheme(),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
              future: authenticationProvider.checkAuthentication(),
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return WaitingScreen();

                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: new Text('Something went wrong...'),
                      );
                    }

                    if (snapshot.data) {
                      //If true is returned, we are logged in
                      return HomepageScreen();
                    } else {
                      //Otherwise, se show the sign-up screen
                      return LandingScreen();
                    }
                }
              },
            ),
      routes: {
        LandingScreen.routeName: (BuildContext ctx) => LandingScreen(),
        LoginScreen.routeName: (BuildContext ctx) => LoginScreen(),
        HomepageScreen.routeName: (BuildContext ctx) => HomepageScreen(),
        SettingsScreen.routeName: (BuildContext ctx) => SettingsScreen(),
        SignUpChoiceScreen.routeName: (BuildContext ctx) => SignUpChoiceScreen(),
        SignUpScreen.routeName: (BuildContext ctx) => SignUpScreen(),
      },
    );
  }
}
