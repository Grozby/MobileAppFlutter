import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_application/providers/refresh_page_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef VoidFunction = void Function();
typedef WidgetBuilder = Widget Function(VoidFunction refreshComplete);

///
/// Widget that allows its child to refresh its content.
/// In order to do so,
/// the child widget must:
/// 1) Accept a [VoidFunction], such that whenever it
/// completes the refreshing procedure, the parent (this class) can update its
/// state.
/// 2) Override its [Widget.didUpdateWidget] method, such that whenever the
/// widget changes, the reload procedure it's triggered.
///
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
/// !!! This widgets act as a SingleChildScrollView !!!
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
///
class RefreshWidget extends StatefulWidget {
  final WidgetBuilder builder;

  RefreshWidget({@required this.builder});

  @override
  _RefreshWidgetState createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  RefreshController _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    RefreshPageProvider provider = RefreshPageProvider();

    return ChangeNotifierProvider(
      create: (_) => provider,
      child: SmartRefresher(
        enablePullUp: false,
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: () async {
          await provider.refresh();
          _refreshController.refreshCompleted();
        },
        header: ClassicHeader(),
        child: RefreshedWidget(builder: widget.builder),
      ),
    );
  }
}

class RefreshedWidget extends StatefulWidget {
  final WidgetBuilder builder;

  RefreshedWidget({@required this.builder});

  @override
  _RefreshedWidgetState createState() => _RefreshedWidgetState();
}

class _RefreshedWidgetState extends State<RefreshedWidget> {
  /// Callback used to signal the parent widget that the refresh has been
  /// completed by the [FutureBuilder]. It uses a
  Function callback = () {};

  /// Stream used to refresh the content of the page, when the parent request
  /// it through the [SmartRefresh] onRefresh method.
  StreamSubscription streamSubscription;
  Stream refreshContentStream;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        var refreshPageProvider = Provider.of<RefreshPageProvider>(context);
        if (refreshPageProvider != null) {
          refreshContentStream = refreshPageProvider.changeNotifier.stream;
          refreshContentStream.listen((callback) {
            setState(() {
              this.callback = callback;
            });
          });
        }
      } catch (e) {}
    });
  }

  @override
  void didUpdateWidget(RefreshedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    try {
      final Stream newRefreshContentStream =
          Provider.of<RefreshPageProvider>(context).changeNotifier.stream;
      // in case the stream instance changed, subscribe to the new one
      if (newRefreshContentStream != refreshContentStream) {
        streamSubscription.cancel();
        refreshContentStream = newRefreshContentStream;
        streamSubscription = refreshContentStream.listen((callback) {
          setState(() {
            this.callback = callback;
          });
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    if (streamSubscription != null) streamSubscription.cancel();
    super.dispose();
  }

  void refreshCompleted() {
    this.callback();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(refreshCompleted);
  }
}
