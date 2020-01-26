import 'package:flutter/material.dart';

class FadedListView<T> extends StatefulWidget {
  final List<T> list;
  final Widget Function(T) builder;
  final double height;

  const FadedListView({
    @required this.list,
    @required this.builder,
    this.height,
  });

  @override
  _FadedListViewState createState() => _FadedListViewState<T>();
}

class _FadedListViewState<T> extends State<FadedListView<T>> {
  ScrollController _controller;
  ScrollPhysics _physics;
  double _elementWidth = 0;
  bool _reachedEnd = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(updatePhysics);
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(updatePhysics);
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_controller.offset >=
            _controller.position.maxScrollExtent -
                (_elementWidth / 3).floor() &&
        !_controller.position.outOfRange) {
      setState(() {
        _reachedEnd = true;
      });
    } else {
      if (_reachedEnd != false) {
        setState(() {
          _reachedEnd = false;
        });
      }
    }
  }

  void updatePhysics() {
    if (_controller.position.haveDimensions && _physics == null) {
      setState(() {
        _physics = PageViewScrollPhysics(itemDimension: _elementWidth / 2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black,
            Colors.transparent,
          ],
          stops: [_reachedEnd ? 1 : 0.7, 1],
        ).createShader(
          Rect.fromLTRB(0, 0, rect.width, rect.height),
        );
      },
      blendMode: BlendMode.dstIn,
      child: Container(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _elementWidth = constraints.maxWidth;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.list.length,
              controller: _controller,
              physics: _physics,
              itemBuilder: (ctx, index) {
                return Container(
                  width: constraints.maxWidth / 2,
                  alignment: Alignment.center,
                  child: widget.builder(widget.list[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PageViewScrollPhysics extends ScrollPhysics {
  final double itemDimension;

  PageViewScrollPhysics({this.itemDimension, ScrollPhysics parent})
      : super(parent: parent);

  @override
  PageViewScrollPhysics applyTo(ScrollPhysics ancestor) {
    return PageViewScrollPhysics(
        itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    return position.pixels / itemDimension;
  }

  double _getPixels(double page) {
    return page * itemDimension;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    return _getPixels(page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
