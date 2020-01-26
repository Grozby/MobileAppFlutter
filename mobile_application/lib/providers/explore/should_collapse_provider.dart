import 'dart:async';

import 'package:flutter/material.dart';

///
/// Simple provider to determine whether the listening collapsable widgets should
/// collapse themselves.
///
class ShouldCollapseProvider with ChangeNotifier {
  final StreamController changeNotifier = StreamController.broadcast();

  void shouldCollapseElements() {
    changeNotifier.sink.add(null);
  }

  @override
  void dispose() {
    changeNotifier.close();
    super.dispose();
  }
}
