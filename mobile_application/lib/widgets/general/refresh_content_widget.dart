import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../providers/refresh_page_provider.dart';

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
  final Widget Function(void Function() refreshComplete) builder;

  RefreshWidget({@required this.builder});

  @override
  _RefreshWidgetState createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  RefreshController _refreshController = RefreshController();
  bool isOverScrolling = false;
  RefreshPageProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = RefreshPageProvider();
  }

  void interruptOverScroll() {
    isOverScrolling = false;
    //Make the drag activity stop.
    _refreshController.position.jumpTo(_refreshController.position.pixels);
  }

  @override
  Widget build(BuildContext context) {
    /// For this class we provide a system where multiple inner scroll views
    /// are managed. In Flutter 1.12.13+hotfix.5, when a inner scroll view
    /// overscrolls, the outer scroll view doesn't move. This make difficult
    /// to scroll the outer view if the inner view covers most of the available
    /// screen space. Therefore, we create an infrastructure that allows the
    /// outer view to scroll, whenever the inner view reaches its boundaries.
    /// To do so, we use three types of notifications:
    /// 1) OverscrollNotification: the one that allows us to know whenever an
    /// overscroll happens in the inner scroll view.
    /// 2) UserScrollNotification: when the UserScrollNotification.direction ==
    /// ScrollDirection.idle, this means that the scroll has ended.
    /// 3) ScrollUpdateNotification: when the user scrolls in the opposite
    /// direction of the overscroll, the outer scroll is returned to its initial
    /// position for simplicity.
    return ChangeNotifierProvider(
      create: (_) => _provider,
      child: NotificationListener<OverscrollNotification>(
        onNotification: (scrollInfo) {
          if(scrollInfo.metrics.axis == Axis.horizontal){
            return false;
          }

          if (scrollInfo.depth != 0) {
            if (!isOverScrolling) {
              isOverScrolling = true;

              /// We define a drag, in order to maintain the outer scroll in
              /// position whenever it changes position.
              _refreshController.position.drag(
                DragStartDetails(
                  globalPosition: Offset(
                    0,
                    scrollInfo.overscroll,
                  ),
                ),
                null,
              );
            }
            try {
              _refreshController.position.setPixels(
                scrollInfo.overscroll + _refreshController.position.pixels,
              );
            } on AssertionError {}
          }

          return false;
        },
        child: NotificationListener<UserScrollNotification>(
          onNotification: (userScrollInfo) {
            if (userScrollInfo.depth != 0) {
              interruptOverScroll();
            }
            return true;
          },
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (scrollUpdate) {
              if (scrollUpdate.depth != 0) {
                interruptOverScroll();
              }
              return true;
            },
            child: SmartRefresher(
              enablePullUp: false,
              enablePullDown: true,
              controller: _refreshController,
              onRefresh: () async {
                await _provider.refresh();
                _refreshController.refreshCompleted();
              },
              header: ClassicHeader(),
              child: RefreshedWidget(builder: widget.builder),
            ),
          ),
        ),
      ),
    );
  }
}

class RefreshedWidget extends StatefulWidget {
  final Widget Function(void Function() refreshComplete) builder;

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
        var refreshPageProvider = Provider.of<RefreshPageProvider>(
          context,
          listen: false,
        );
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
          Provider.of<RefreshPageProvider>(context, listen: false)
              .changeNotifier
              .stream;
      // in case the stream instance changed, subscribe to the new one
      if (newRefreshContentStream != refreshContentStream) {
        streamSubscription?.cancel();
        refreshContentStream = newRefreshContentStream;
        streamSubscription = refreshContentStream.listen((callback) {
          setState(() {
            this.callback = callback;
          });
        });
      }
    } catch (e) {
      print("Eccoci");
    }
  }

  @override
  void dispose() {
    if (streamSubscription != null) {
      streamSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollNotification>(
      onNotification: (scrollInfo) {
        return !(scrollInfo.overscroll < 0);
      },
      child: NotificationListener<UserScrollNotification>(
        onNotification: (userScrollInfo) {
          return userScrollInfo.direction != ScrollDirection.idle;
        },
        child: NotificationListener<ScrollUpdateNotification>(
          onNotification: (scrollNotification) {
            return !context
                .findAncestorStateOfType<_RefreshWidgetState>()
                .isOverScrolling;
          },
          child: widget.builder(callback),
        ),
      ),
    );
  }
}
