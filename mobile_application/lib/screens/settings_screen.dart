import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile_application/providers/theming/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ryfy'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Provider.of<ThemeProvider>(context).switchTheme();
          },
          child: const Text('Switch theme'),
        ),
      ),
    );
  }
}
