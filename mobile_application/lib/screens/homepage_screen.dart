import 'package:flutter/material.dart';

import 'settings_screen.dart';

class HomepageScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Ryfy'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
          ),
        ],
      ),
      body: Center(
        child: const Text('Homepage'),
      ),
    );
  }
}
