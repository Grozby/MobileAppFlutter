import 'package:flutter/material.dart';

class ButtonStyled extends StatelessWidget {
  final int dimensionButton;
  final Color color;
  final Function onPressFunction;
  final String text;

  ButtonStyled({
    @required this.dimensionButton,
    @required this.onPressFunction,
    @required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(),
        ),
        Expanded(
          flex: dimensionButton,
          child: RaisedButton(
            color: color,
            child: Text(text),
            onPressed: onPressFunction,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}
