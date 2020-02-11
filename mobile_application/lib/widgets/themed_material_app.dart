import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ryfy/providers/chat/chat_provider.dart';
import 'package:ryfy/providers/database/database_provider.dart';
import 'package:ryfy/providers/explore/card_provider.dart';
import 'package:ryfy/providers/user/user_data_provider.dart';

import '../models/exceptions/no_internet_exception.dart';
import '../models/exceptions/something_went_wrong_exception.dart';
import '../providers/authentication/authentication_provider.dart';
import '../providers/theming/theme_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/homepage_screen.dart';
import '../screens/initialization_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sign_up_screens/sign_up_choice_screen.dart';
import '../screens/sign_up_screens/sign_up_screen.dart';
import '../screens/single_chat_screen.dart';
import '../screens/user_profile_edit_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/waiting_screen.dart';
import '../widgets/general/loading_error.dart';
import 'general/custom_alert_dialog.dart';

class ThemedMaterialApp extends StatefulWidget {
  @override
  _ThemedMaterialAppState createState() => _ThemedMaterialAppState();
}

class _ThemedMaterialAppState extends State<ThemedMaterialApp> {
  ThemeProvider currentTheme;
  AuthenticationProvider authenticationProvider;
  DatabaseProvider databaseProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isLogged = Provider.of<AuthenticationProvider>(context).isLogged;
    if (authenticationProvider == null ||
        isLogged != authenticationProvider.isLogged) {
      currentTheme = Provider.of<ThemeProvider>(context);
      authenticationProvider = Provider.of<AuthenticationProvider>(context);
      databaseProvider = Provider.of<DatabaseProvider>(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Provider.of<ThemeProvider>(context).overlayStyle,
      child: MultiProvider(
        providers: [
          ChangeNotifierProxyProvider<AuthenticationProvider, UserDataProvider>(
            create: (_) => UserDataProvider(
              httpRequestWrapper: authenticationProvider.httpRequestWrapper,
              databaseProvider: databaseProvider,
            ),
            update: (_, authP, previous) => UserDataProvider(
              httpRequestWrapper: authP.httpRequestWrapper,
              databaseProvider: databaseProvider,
            ),
          ),
          ChangeNotifierProxyProvider<AuthenticationProvider, CardProvider>(
            create: (_) => CardProvider(
              authenticationProvider.httpRequestWrapper,
            ),
            update: (_, authP, previous) =>
                CardProvider(authP.httpRequestWrapper),
          ),
          ChangeNotifierProxyProvider<AuthenticationProvider, ChatProvider>(
            create: (_) => ChatProvider(
              httpRequestWrapper: authenticationProvider.httpRequestWrapper,
              databaseProvider: databaseProvider,
              fcmToken: authenticationProvider.fcmToken,
            ),
            update: (_, authP, previous) => ChatProvider(
              httpRequestWrapper: authP.httpRequestWrapper,
              databaseProvider: databaseProvider,
              fcmToken: authP.fcmToken,
            ),
          ),
        ],
        child: MaterialApp(
          theme: currentTheme.getTheme(),
          debugShowCheckedModeBanner: false,
          home: FutureBuilder(
            future: authenticationProvider.checkAuthentication(),
            builder: (ctx, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const WaitingScreen();

                default:
                  if (snapshot.hasError) {
                    if (snapshot.error is NoInternetException) {
                      if (authenticationProvider.gotAToken()) {
                        return HomepageScreen();
                      }
                      return Scaffold(
                        body: SafeArea(
                          child: LoadingError(
                            exception: snapshot.error,
                            retry: () => setState(() {}),
                            buildContext: context,
                          ),
                        ),
                      );
                    } else {
                      Future.delayed(
                        Duration.zero,
                        () => showErrorDialog(
                          ctx,
                          snapshot.error is SomethingWentWrongException
                              ? (snapshot.error as SomethingWentWrongException)
                                  .text
                              : "Got some error.",
                        ),
                      );
                      return LandingScreen();
                    }
                  }

                  if (snapshot.data as bool) {
                    //If true is returned, we are logged in
                    return const HomepageScreen();
                  } else {
                    //Otherwise, we show the sign-up screen
                    if (authenticationProvider.wasLogged) {
                      Future.delayed(
                        Duration.zero,
                        () => showErrorDialog(
                          ctx,
                          "You have been logged out. Log in again.",
                        ),
                      );
                    }

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
            UserProfileScreen.routeName: (ctx) => UserProfileScreen(
                ModalRoute.of(ctx).settings.arguments as UserProfileArguments),
            UserProfileEditScreen.routeName: (_) => UserProfileEditScreen(),
            InitializationScreen.routeName: (_) => InitializationScreen(),
            ChatListScreen.routeName: (_) => ChatListScreen(),
            SingleChatScreen.routeName: (ctx) => SingleChatScreen(
                ModalRoute.of(ctx).settings.arguments as SingleChatArguments),
          },
        ),
      ),
    );
  }
}
