import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/authentication/authentication_provider.dart';
import '../../providers/theming/theme_provider.dart';

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
    Provider.of<AuthenticationProvider>(context, listen: false).logout();
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  void switchTheme() async {
    await themeProvider.switchTheme();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        child: Drawer(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: themeProvider.drawerBackgroundColor,
            child: Column(
              children: <Widget>[
                ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  title: Text(
                    'Ryfy',
                    style: Theme.of(context).textTheme.display2.copyWith(
                          fontSize: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.brightness_6,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  title: Text(
                    'Change theme',
                    style: Theme.of(context).textTheme.title.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  onTap: switchTheme,
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Center(),
                ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  title: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.title.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  onTap: logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
