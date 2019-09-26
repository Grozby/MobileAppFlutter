import 'package:flutter/material.dart';

class ButtonStyled extends StatelessWidget {
  final double fractionalWidthDimension;
  final double radius = 30.0;
  final Color color;
  final Function onPressFunction;
  final String text;

  ButtonStyled({
    @required this.fractionalWidthDimension,
    @required this.onPressFunction,
    @required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: fractionalWidthDimension,
        child: RaisedButton(
          color: color,
          child: Text(text),
          onPressed: onPressFunction,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
