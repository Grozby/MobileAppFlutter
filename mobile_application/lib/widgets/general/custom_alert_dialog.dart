import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String text;

  CustomAlertDialog(this.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('An error occured'),
      content: Text(text),
      actions: <Widget>[
        FlatButton(
          child: const Text('Okay'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  void removeOverlay(BuildContext context){
    Navigator.of(context).pop();
  }
}

void showErrorDialog(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (ctx) => CustomAlertDialog(text),
  );
}
