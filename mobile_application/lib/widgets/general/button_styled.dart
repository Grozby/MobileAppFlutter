import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ButtonStyled extends StatelessWidget {
  final double fractionalWidthDimension;
  final double radius = 30.0;
  final Color color;
  final Function onPressFunction;
  final String text;

  const ButtonStyled({
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
          child: AutoSizeText(text),
          onPressed: onPressFunction,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
