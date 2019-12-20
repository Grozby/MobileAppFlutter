import 'package:flutter/material.dart';

import 'button_styled.dart';

class NoInternetConnectionWidget extends StatelessWidget {
  final Function retryToConnect;
  final String errorText;

  const NoInternetConnectionWidget({
    @required this.retryToConnect,
    @required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(errorText),
        ),
        const SizedBox(height: 16),
        Center(
          child: ButtonStyled(
            fractionalWidthDimension: 0.4,
            text: "Retry now",
            onPressFunction: retryToConnect,
          ),
        ),
      ],
    );
  }
}
