import 'package:flutter/material.dart';

class InitializationScreen extends StatelessWidget {
  static const routeName = '/initialize';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Text(
                "Welcome to RyFy!",
                style: Theme.of(context).textTheme.title,
              ),
            ),
            Center(
              child: Text("Eccoci"),
            ),
          ],
        ),
      ),
    );
  }
}
