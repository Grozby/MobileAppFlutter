import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/custom_alert_dialog.dart';

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
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 1)),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            Future.delayed(
              Duration.zero,
                  () => showErrorDialog(context, "Something went wrong..."),
            );
          }

          
        },
      ),
    );
  }
}
