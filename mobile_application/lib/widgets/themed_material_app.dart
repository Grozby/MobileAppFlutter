import 'package:flutter/material.dart';
import 'package:mobile_application/models/exceptions/no_internet_exception.dart';
import 'package:provider/provider.dart';

import '../models/exceptions/something_went_wrong_exception.dart';
import '../providers/authentication/authentication_provider.dart';
import '../providers/theming/theme_provider.dart';
import '../screens/homepage_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sign_up_screens/sign_up_choice_screen.dart';
import '../screens/sign_up_screens/sign_up_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/waiting_screen.dart';
import 'general/custom_alert_dialog.dart';
import 'general/no_internet_connection.dart';

class ThemedMaterialApp extends StatefulWidget {
  @override
  _ThemedMaterialAppState createState() => _ThemedMaterialAppState();
}

class _ThemedMaterialAppState extends State<ThemedMaterialApp> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context);
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);

    return MaterialApp(
      theme: currentTheme.getTheme(),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: authenticationProvider.checkAuthentication() ?? null,
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const WaitingScreen();

            default:
              if (snapshot.hasError) {
                if (snapshot.error is NoInternetException) {
                  Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                      context,
                      (snapshot.error as NoInternetException).getMessage(),
                    ),
                  );
                  return Scaffold(
                    body: NoInternetConnectionWidget(
                      retryToConnect: () => setState(() {}),
                      errorText:
                          (snapshot.error as NoInternetException).getMessage(),
                    ),
                  );
                } else {
                  Future.delayed(
                    Duration.zero,
                    () => showErrorDialog(
                      ctx,
                      snapshot.error is SomethingWentWrongException
                          ? (snapshot.error as SomethingWentWrongException).text
                          : "Got some error.",
                    ),
                  );
                  return LandingScreen();
                }
              }

              if (snapshot.data) {
                //If true is returned, we are logged in
                return const HomepageScreen();
              } else {
                //Otherwise, we show the sign-up screen
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
        UserProfileScreen.routeName: (_) => UserProfileScreen(),
        MessagesScreen.routeName: (_) => MessagesScreen(),
      },
    );
  }
}
