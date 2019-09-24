import 'package:flutter/material.dart';

class CircularButtonInfoBar extends StatelessWidget {
  final String assetPath;
  final Function onPressFunction;

  CircularButtonInfoBar({
    @required this.assetPath,
    @required this.onPressFunction,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.55,
      child: Stack(
        children: <Widget>[
          Center(
            child: Material(
              color: Colors.transparent,
              elevation: 4,
              shape: CircleBorder(),
              child: Container(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: RawMaterialButton(
              shape: CircleBorder(),
              onPressed: onPressFunction,
              child: Container(),
            ),
          )
        ],
      ),
    );
  }
}
