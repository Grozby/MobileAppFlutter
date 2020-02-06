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
    await Provider.of<AuthenticationProvider>(context, listen: false).logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      Navigator.defaultRouteName,
      ModalRoute.withName(""),
    );
  }

  void switchTheme() async {
    await themeProvider.switchTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Drawer(
        child: Container(
          color: themeProvider.drawerBackgroundColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
