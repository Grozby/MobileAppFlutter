import 'package:flutter/material.dart';

import 'button_styled.dart';

class NoInternetConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Center(
            child: Text("RyFy servers are down. Try to reconnect."),
          ),
          Center(
            child: ButtonStyled(
              fractionalWidthDimension: 0.4,
              text: "Retry now",
              onPressFunction: () {},
            ),
          ),
        ],
      ),
    );
  }
}
