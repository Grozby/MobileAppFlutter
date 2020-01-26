import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/explore/should_collapse_provider.dart';

///
/// Support widget that allows its [child] to be expandable. The starting height
/// of the widget is determined by the [height] field, while the
/// [durationInMilliseconds] field determine the animation duration for the
/// expansion.
///
class ExpandableWidget extends StatefulWidget {
  final int durationInMilliseconds;
  final double height;
  final Widget child;

  ExpandableWidget({
    @required this.durationInMilliseconds,
    @required this.height,
    @required this.child,
  });

  @override
  _ExpandableWidgetState createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded;
  double actualWidgetHeight;
  GlobalKey _keyFoldChild;
  AnimationController _controller;
  Animation<double> _sizeAnimation;

  //We use these streams in order to listen to external events, given by the
  //stream inside the ShouldCollapseProvider.
  StreamSubscription streamSubscription;
  Stream shouldCollapseStream;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
    );
    _keyFoldChild = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    Future.delayed(Duration.zero, () {
      //If we have a stream, we subscribe to it. Whenever we have a
      //a change, we collapse the widget.
      try {
        var shouldCollapseProvider =
            Provider.of<ShouldCollapseProvider>(context);
        if (shouldCollapseProvider != null) {
          shouldCollapseStream = shouldCollapseProvider.changeNotifier.stream;
          shouldCollapseStream.listen((_) => collapse());
        }
      } catch (e) {}
    });
  }

  @override
  void didUpdateWidget(ExpandableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    try {
      final Stream newShouldCollapseStream =
          Provider.of<ShouldCollapseProvider>(context).changeNotifier.stream;
      // in case the stream instance changed, subscribe to the new one
      if (newShouldCollapseStream != shouldCollapseStream) {
        streamSubscription.cancel();
        shouldCollapseStream = newShouldCollapseStream;
        streamSubscription = shouldCollapseStream.listen((_) => collapse());
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    if (streamSubscription != null) streamSubscription.cancel();
    super.dispose();
  }

  ///
  /// Support functions
  ///
  void onTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _afterLayout(_) {
    final RenderBox renderBox = _keyFoldChild.currentContext.findRenderObject();
    setState(() {
      actualWidgetHeight = renderBox.size.height;
    });

    _sizeAnimation = Tween<double>(
      begin: widget.height < actualWidgetHeight
          ? widget.height
          : actualWidgetHeight,
      end: actualWidgetHeight,
    ).animate(_controller);
  }

  void collapse() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return (actualWidgetHeight ?? widget.height) > widget.height
            ? InkWell(
                onTap: onTap,
                child: Column(
                  children: <Widget>[
                    _isExpanded
                        ? Container(
                            child: ClipRect(
                              child: SizedOverflowBox(
                                alignment: Alignment.topCenter,
                                size: Size(
                                  double.infinity,
                                  _sizeAnimation?.value ?? widget.height - 12,
                                ),
                                child: child,
                              ),
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                ],
                                stops: [0.7, 1],
                              ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height),
                              );
                            },
                            blendMode: BlendMode.dstIn,
                            child: Container(
                              child: ClipRect(
                                child: SizedOverflowBox(
                                  alignment: Alignment.topCenter,
                                  size: Size(
                                    double.infinity,
                                    _sizeAnimation?.value ?? widget.height - 12,
                                  ),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                    Container(
                      height: 12,
                      width: double.infinity,
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              )
            : ClipRect(
                child: SizedOverflowBox(
                  alignment: Alignment.topCenter,
                  size: Size(
                    double.infinity,
                    _sizeAnimation?.value ??
                        actualWidgetHeight ??
                        widget.height,
                  ),
                  child: child,
                ),
              );
      },
      child: Container(
        key: _keyFoldChild,
        child: widget.child,
      ),
    );
  }
}
