import 'package:flutter/material.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
