import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/authentication/authentication_provider.dart';
import 'providers/configuration.dart';
import 'providers/explore/card_provider.dart';
import 'providers/theming/theme_provider.dart';
import 'providers/user/user_data_provider.dart';
import 'widgets/themed_material_app.dart';

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

void main() async {
  //Force the app to work only in portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup the Http manager
  Dio _httpManager = Dio(
    BaseOptions(
      baseUrl: Configuration.serverUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      sendTimeout: 4000,
    ),
  );
  (_httpManager.transformer as DefaultTransformer).jsonDecodeCallback =
      parseJson;

  var themeProvider = ThemeProvider();
  var authenticationProvider = AuthenticationProvider(_httpManager);
  var userDataProvider = UserDataProvider();
  var cardProvider = CardProvider(_httpManager);

  await themeProvider.loadThemePreference();
  await authenticationProvider.loadAuthentication();

  return runApp(
    MyApp(
      themeProvider: themeProvider,
      authenticationProvider: authenticationProvider,
      userDataProvider: userDataProvider,
      cardProvider: cardProvider,
    ),
  );
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AuthenticationProvider authenticationProvider;
  final UserDataProvider userDataProvider;
  final CardProvider cardProvider;

  MyApp({
    @required this.themeProvider,
    @required this.authenticationProvider,
    @required this.userDataProvider,
    @required this.cardProvider,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.authenticationProvider,
        ),
        ChangeNotifierProvider.value(
          value: widget.themeProvider,
        ),
        ChangeNotifierProvider.value(
          value: widget.userDataProvider,
        ),
        ChangeNotifierProvider.value(
          value: widget.cardProvider,
        ),
      ],
      child: ThemedMaterialApp(),
    );
  }
}
