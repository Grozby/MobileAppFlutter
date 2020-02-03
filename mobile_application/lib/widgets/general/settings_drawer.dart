import 'package:flutter/material.dart';
import 'package:mobile_application/providers/authentication/authentication_provider.dart';
import 'package:mobile_application/providers/theming/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  void logout() async {
    await Provider.of<AuthenticationProvider>(context).logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      Navigator.defaultRouteName,
      ModalRoute.withName(""),
    );
  }

  void switchTheme() {
    Provider.of<ThemeProvider>(context).switchTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.drawerBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Ryfy',
                      style: themeProvider.getTheme().textTheme.display2,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.exit_to_app,
                      color: themeProvider.getTheme().primaryColorLight,
                    ),
                    title: Text(
                      'Logout',
                      style: themeProvider.getTheme().textTheme.title.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    onTap: logout,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.brightness_6,
                      color: themeProvider.getTheme().primaryColorLight,
                    ),
                    title: Text(
                      'Change theme',
                      style: themeProvider.getTheme().textTheme.title.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: switchTheme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
