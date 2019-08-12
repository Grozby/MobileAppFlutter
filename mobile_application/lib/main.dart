import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/authentication/authentication_provider.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'widgets/themed_material_app.dart';

void main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  var themeProvider = ThemeProvider();
  var authenticationProvider = AuthenticationProvider();

  await themeProvider.loadThemePreference();
  await authenticationProvider.loadAuthentication();
  return runApp(MyApp(
    themeProvider: themeProvider,
    authenticationProvider: authenticationProvider,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final AuthenticationProvider authenticationProvider;

  MyApp({
    @required this.themeProvider,
    @required this.authenticationProvider,
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
      ],
      child: ThemedMaterialApp(),
    );
  }
}
