import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/general/audio_widget.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Sound'),
          ),
          body: Center(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              heightFactor: 0.5,
              child: AudioWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
