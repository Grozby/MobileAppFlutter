import 'package:flutter/material.dart';

import 'button_styled.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          const Center(
            child: const Text("RyFy servers are down. Try to reconnect."),
          ),
          Center(
            child: ButtonStyled(
              fractionalWidthDimension: 0.4,
              text: "Retry now",
              //TODO
              onPressFunction: () {},
            ),
          ),
        ],
      ),
    );
  }
}
