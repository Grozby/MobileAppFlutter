import 'package:flutter/material.dart';

import 'expandable_widget.dart';

class ShowGrid<T> extends StatelessWidget {
  final List<T> list;
  final Widget Function(T) builder;
  final double height;
  final int durationExpansion;

  ShowGrid({
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
