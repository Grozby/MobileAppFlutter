import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'explore_screen_widgets.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final Function rotateCard;

  CardContainer({
    @required this.child,
    @required this.rotateCard,
  })  : assert(child != null),
        assert(rotateCard != null);

  @override
  Widget build(BuildContext context) {
    double height = ScopedModel.of<AvailableSizes>(context).height;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          minHeight: height - 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4],
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.10),
              const Color(0xFFFFFF),
            ],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: rotateCard,
          child: child,
        ),
      ),
    );
  }
}
