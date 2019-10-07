import 'dart:async';

import 'package:flutter/material.dart';

class ShouldCollapseProvider with ChangeNotifier {
  final changeNotifier = new StreamController.broadcast();

  void shouldCollapseElements() {
    changeNotifier.sink.add(null);
  }

  @override
  void dispose() {
    changeNotifier.close();
    super.dispose();
  }
}
