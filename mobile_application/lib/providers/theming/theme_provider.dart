import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/custom_route.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _isLight;
  static const Color _mentorColor = Color.fromRGBO(234, 128, 59, 1);
  static const Color _mentorCardColor = Color.fromRGBO(234, 128, 59, 1);
  static const Color _menteeColor = Color.fromRGBO(0, 119, 181, 1);
  static const Color _menteeCardColor = Color(0x6CD1F4);

  static const Color _primaryColor = _mentorColor;
  static Color _loginButtonColor = Colors.grey.shade200;
  static const Color _textColor = Color.fromRGBO(68, 86, 108, 1);
  static const Color _greyTextColor = Color.fromRGBO(161, 170, 181, 1);

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
    textTheme: ThemeData.light().textTheme.copyWith(
        display3: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: _textColor,
        ),
        display2: TextStyle(
          fontSize: 24.0,
          color: _textColor,
          fontWeight: FontWeight.w700,
        ),
        display1: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
        subhead: TextStyle(
          fontSize: 16,
          color: _greyTextColor,
        ),
        title: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textColor,
        ),
        overline: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _greyTextColor,
          letterSpacing: 0,
        ),
        body1: TextStyle(
          fontSize: 16,
          color: Color.fromRGBO(105, 120, 137, 1),
        )),
  );

  /*----------
     Methods
   -----------*/

  ThemeData getTheme() => _themeData;

  static Color get primaryColor => _primaryColor;

  static Color get mentorColor => _mentorColor;
  static Color get mentorCardColor => _mentorCardColor.withOpacity(0.1);

  static Color get menteeColor => _menteeColor;
  static Color get menteeCardColor => _menteeCardColor.withOpacity(0.1);

  static Color get loginButtonColor => _loginButtonColor;

  static Color get greyColor => _greyTextColor;

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
