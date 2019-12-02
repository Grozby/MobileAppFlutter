import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/transition/loading_animated.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
        child: const LoadingAnimated(),
      ),
    );
  }
}
