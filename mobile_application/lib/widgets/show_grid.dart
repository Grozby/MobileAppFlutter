import 'package:flutter/material.dart';

import 'expandable_widget.dart';

///
/// Utility widget that shows a given [list] of type [T] in rows, two by two columns.
/// In case of a odd number of elements in the list, the last row will contain
/// only one column, without any placeholder (unlike the [Table] widget.).
/// The information of T will be showed by an apposite widget. This widget
/// will be created by an apposite [builder] function passed as an argument to
/// [ShowGridInPairs].
/// The [durationExpansion] will determine the time in milliseconds that will
/// take the expansion of the grid, while the [height] will determine the
/// starting height of the widget. In case the widget default dimensions will
/// fit inside the given [height], then no expansion will be needed. Otherwise,
/// it will be possible to expand the widget by tapping it, thanks to the
/// [ExpandableWidget].
///
class ShowGridInPairs<T> extends StatelessWidget {
  final List<T> list;
  final Widget Function(T) builder;
  final double height;
  final int durationExpansion;

  ShowGridInPairs({
    @required this.list,
    @required this.builder,
    @required this.height,
    @required this.durationExpansion,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableWidget(
      height: height,
      durationInMilliseconds: durationExpansion,
      child: Container(
        color: Colors.white,
        child: Column(
          children: List<Row>.generate(
            (list.length / 2).ceil(),
                (index) {
              var elements = [builder(list[index * 2])];
              if ((index * 2 + 1) < list.length) {
                elements.add(builder(list[index * 2 + 1]));
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: elements,
              );
            },
          ),
        ),
      ),
    );
  }
}
