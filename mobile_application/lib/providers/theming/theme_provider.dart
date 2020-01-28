import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/custom_route.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  SystemUiOverlayStyle _overlayStyle;
  Map<String, Color> _chatColors;

  bool _isLight;
  static const Color _mentorColor = Color.fromRGBO(234, 128, 59, 1);
  static const Color _mentorCardColor = Color.fromRGBO(234, 128, 59, 1);
  static const Color _menteeColor = Color.fromRGBO(0, 119, 181, 1);
  static const Color _menteeCardColor = Color(0x6CD1F4);

  static const Color _primaryColor = _mentorColor;
  static const Color _primaryLighterColor = Color(0xFFFFB069);
  static Color _loginButtonColor = Colors.grey.shade200;
  static const Color _textColor = Color.fromRGBO(68, 86, 108, 1);
  static const Color _greyTextColor = Color.fromRGBO(161, 170, 181, 1);
  static const Color _lightGreyTextColor = Color.fromRGBO(211, 220, 231, 1);

  static const Map<String, Color> _lightChatColors = {
    "currentUser": _primaryColor,
    "otherUser": Colors.white,
    "border": Color(0xFFE0E0E0),
  };

  static const Map<String, Color> _darkChatColors = {
    "currentUserColorChat": _primaryColor,
    "otherUserColorChat": Colors.white,
    "border": Colors.white,
  };

  static const SystemUiOverlayStyle _lightOverlayStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: null,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle _darkOverlayStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: null,
    statusBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
  );

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
          ),
          body2: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
  );

  ThemeData _darkTheme = ThemeData.dark().copyWith(
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
            color: _lightGreyTextColor,
          ),
          display2: TextStyle(
            fontSize: 24.0,
            color: _lightGreyTextColor,
            fontWeight: FontWeight.w700,
          ),
          display1: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          subhead: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          title: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _lightGreyTextColor,
          ),
          overline: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _lightGreyTextColor,
            letterSpacing: 0,
          ),
          body1: TextStyle(
            fontSize: 16,
            color: Color.fromRGBO(105, 120, 137, 1),
          ),
          body2: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
  );

  /*----------
     Methods
   -----------*/

  ThemeData getTheme() => _themeData;

  SystemUiOverlayStyle get overlayStyle => _overlayStyle;

  Map<String, Color> get chatColors => _chatColors;

  static Color get primaryColor => _primaryColor;

  static Color get primaryLighterColor => _primaryLighterColor;

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

    /// If nothing is contained in memory or light is stored, we show the
    /// light theme. Otherwise, the dark theme will show.
    if (preferences.containsKey('theme') &&
        preferences.getString('theme') == "dark") {
      _themeData = _darkTheme;
      _overlayStyle = _darkOverlayStyle;
      _chatColors = _darkChatColors;
      _isLight = false;
    } else {
      _themeData = _lightTheme;
      _overlayStyle = _lightOverlayStyle;
      _chatColors = _lightChatColors;
      _isLight = true;
    }
  }

  Future<void> switchTheme() async {
    if (_isLight) {
      _themeData = _darkTheme;
      _overlayStyle = _darkOverlayStyle;
      _chatColors = _lightChatColors;
    } else {
      _themeData = _lightTheme;
      _overlayStyle = _lightOverlayStyle;
      _chatColors = _darkChatColors;
    }

    _isLight = !_isLight;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('theme', _isLight ? 'light' : 'dark');
  }
}
