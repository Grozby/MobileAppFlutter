import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/custom_route.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _isLight;
  static Color _mentorColor = Color.fromRGBO(234, 128, 59, 1);
  static Color _primaryColor = _mentorColor;
  static Color _menteeColor = Color.fromRGBO(0, 119, 181, 1);
  static Color _loginButtonColor = Colors.grey.shade200;

  ThemeData _lightTheme = ThemeData.light().copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CustomPageTransitionBuilder(),
        TargetPlatform.iOS: CustomPageTransitionBuilder(),
      },
    ),
    primaryColor: _primaryColor,
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      buttonColor: Color.fromRGBO(234, 128, 59, 1),
    ),
    cursorColor: Colors.grey,
  );

  /*----------
     Methods
   -----------*/

  ThemeData getTheme() => _themeData;

  static Color get primaryColor => _primaryColor;

  static Color get mentorColor => _mentorColor;

  static Color get menteeColor => _menteeColor;

  static Color get loginButtonColor => _loginButtonColor;

  void setTheme(ThemeData newTheme) {
    _themeData = newTheme;
    notifyListeners();
  }

  Future<void> loadThemePreference() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('theme')) {
      final themePreference = preferences.getString('theme');
      if (themePreference == 'light') {
        _themeData = _lightTheme;
        _isLight = true;
      } else {
        _themeData = ThemeData.dark();
        _isLight = false;
      }
    } else {
      _themeData = _lightTheme;
      _isLight = true;
    }
  }

  Future<void> switchTheme() async {
    if (_isLight) {
      _themeData = ThemeData.dark();
    } else {
      _themeData = _lightTheme;
    }

    _isLight = !_isLight;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('theme', _isLight ? 'light' : 'dark');
  }
}
