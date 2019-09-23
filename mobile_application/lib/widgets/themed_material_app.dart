import 'package:flutter/material.dart';
import 'package:mobile_application/models/exceptions/something_went_wrong_exception.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:provider/provider.dart';

import '../providers/authentication/authentication_provider.dart';
import '../screens/homepage_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sign_up_screens/sign_up_choice_screen.dart';
import '../screens/sign_up_screens/sign_up_screen.dart';
import '../screens/waiting_screen.dart';
import 'custom_alert_dialog.dart';

class ThemedMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);

    return MaterialApp(
      theme: currentTheme.getTheme(),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        //TODO re-add authentication check
        //future: authenticationProvider.checkAuthentication(),
        future: Future.delayed(
          Duration.zero,
          () => true,
        ),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return WaitingScreen();

            default:
              if (snapshot.hasError) {
                Future.delayed(
                  Duration.zero,
                  () => showErrorDialog(ctx,
                      (snapshot.error as SomethingWentWrongException).text),
                );
                return LandingScreen();
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
        LandingScreen.routeName: (_) => LandingScreen(),
        LoginScreen.routeName: (_) => LoginScreen(),
        HomepageScreen.routeName: (_) => HomepageScreen(),
        SettingsScreen.routeName: (_) => SettingsScreen(),
        SignUpChoiceScreen.routeName: (_) => SignUpChoiceScreen(),
        SignUpScreen.routeName: (_) => SignUpScreen(),
      },
    );
  }
}
