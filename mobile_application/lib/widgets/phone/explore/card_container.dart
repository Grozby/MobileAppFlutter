import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/utility/available_sizes.dart';
import '../../../providers/theming/theme_provider.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final Function rotateCard;
  static const double padding = 12;
  final bool canExpand;
  final Color startingColor;

  CardContainer({
    @required this.child,
    @required this.rotateCard,
    this.canExpand = true,
    startingColor,
  })  : assert(child != null),
        assert(rotateCard != null),
        this.startingColor = startingColor != null
            ? startingColor
            : ThemeProvider.primaryColor.withOpacity(0.10);

  @override
  Widget build(BuildContext context) {
    double height = ScopedModel.of<AvailableSizes>(context).height;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(padding),
        height: canExpand ? null : height - padding * 2,
        constraints: BoxConstraints(
          minHeight: height - padding * 2,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(const Radius.circular(24.0)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.4],
            colors: [
              startingColor,
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
