import 'dart:async';

import 'package:flutter/material.dart';


class RefreshPageProvider with ChangeNotifier {
  final changeNotifier = StreamController.broadcast();

  Future<void> refresh() async {
    /// A stream is used for notify the provider that the refresh procedure
    /// has been concluded. To do so, we open a stream, and wait until it's
    /// closed. The listener to this provider will be the one that calls the
    /// callback, that will close the stream.
    /// In this way, the [SmartRefresher] onRefresh method can wait for
    /// the its child to refresh the content, and then call
    /// [RefreshController.refreshComplete()].
    StreamController internStream = StreamController.broadcast();
    /// We pass a simple callback that immediately close a stream.
    changeNotifier.sink.add(() {
      internStream.close();
    });
    await for (dynamic _ in internStream.stream) {}
  }

  @override
  void dispose() {
    changeNotifier.close();
    super.dispose();
  }
}
