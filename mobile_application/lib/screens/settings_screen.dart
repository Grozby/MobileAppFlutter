import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/authentication/authentication_provider.dart';
import '../providers/theming/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: RaisedButton(
                onPressed: () {
                  Provider.of<ThemeProvider>(context).switchTheme();
                },
                child: const Text('Switch theme'),
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: () async {
                  await Provider.of<AuthenticationProvider>(
                    context,
                    listen: false,
                  ).logout();
                  await Navigator.of(context).pushNamedAndRemoveUntil(
                    Navigator.defaultRouteName,
                    ModalRoute.withName(""),
                  );

                },
                child: const Text('Logout'),
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
