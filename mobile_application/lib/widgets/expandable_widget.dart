import 'dart:ui';

import 'package:flutter/material.dart';

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

  void _afterLayout(_) {
    final RenderBox renderBox = _keyFoldChild.currentContext.findRenderObject();
    setState(() {
      actualWidgetHeight = renderBox.size.height;
    });

    _sizeAnimation = Tween<double>(
      begin: widget.height,
      end: actualWidgetHeight,
    ).animate(_controller);
  }

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                        ? ClipRect(
                            child: SizedOverflowBox(
                              alignment: Alignment.topCenter,
                              size: Size(
                                double.infinity,
                                _sizeAnimation?.value ?? widget.height - 12,
                              ),
                              child: child,
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
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
                      double.infinity, _sizeAnimation?.value ?? widget.height),
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
