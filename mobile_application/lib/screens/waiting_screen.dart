import 'package:flutter/material.dart';

import '../widgets/transition/loading_animated.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: LoadingAnimated(),
        ),
      ),
    );
  }
}
