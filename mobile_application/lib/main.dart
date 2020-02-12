import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/authentication/authentication_provider.dart';
import 'providers/configuration.dart';
import 'providers/database/database_provider.dart';
import 'providers/notification/notification_provider.dart';
import 'providers/theming/theme_provider.dart';
import 'widgets/themed_material_app.dart';

///
/// Methods for parsing json with DIO
///
_parseAndDecode(String response) => jsonDecode(response);

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

///
/// Main
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Force the app to work only in portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  initializeDateFormatting();

  ///
  /// Creation of all needed data for the http manager
  ///
  var options = BaseOptions(
    baseUrl: Configuration.serverUrl,
    receiveTimeout: 8000,
    sendTimeout: 5000,
  );

  // Setup the Http manager
  var _httpManager = Dio(options);
  (_httpManager.transformer as DefaultTransformer).jsonDecodeCallback =
      parseJson;

  ///
  /// Initialization providers
  ///
  var databaseProvider = DatabaseProvider();
  await databaseProvider.getDatabase();
  var notificationProvider = NotificationProvider();
  await notificationProvider.initialize();

  var themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();
  var authenticationProvider = AuthenticationProvider(
    _httpManager,
    databaseProvider: databaseProvider,
  );
  await authenticationProvider.loadAuthentication();

  authenticationProvider.fcmToken = await notificationProvider.fcmToken;

  runApp(
    MyApp(
      themeProvider: themeProvider,
      authenticationProvider: authenticationProvider,
      databaseProvider: databaseProvider,
      notificationProvider: notificationProvider,
    ),
  );
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AuthenticationProvider authenticationProvider;
  final DatabaseProvider databaseProvider;
  final NotificationProvider notificationProvider;

  MyApp({
    @required this.themeProvider,
    @required this.authenticationProvider,
    @required this.databaseProvider,
    @required this.notificationProvider,
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
          value: widget.databaseProvider,
        ),
        ChangeNotifierProvider.value(
          value: widget.notificationProvider,
        ),
      ],
      child: ThemedMaterialApp(),
    );
  }
}
