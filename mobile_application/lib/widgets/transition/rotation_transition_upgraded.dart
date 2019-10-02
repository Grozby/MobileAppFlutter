import 'dart:math' as math;

import 'package:flutter/material.dart';

class RotationTransitionUpgraded extends AnimatedWidget {
  Animation<double> get turns => listenable;
  final Alignment alignment;
  final Widget child;
  final bool isShowing;

  const RotationTransitionUpgraded({
    Key key,
    @required Animation<double> turns,
    this.alignment = Alignment.center,
    this.child,
    this.isShowing,
  })  : assert(turns != null),
        super(key: key, listenable: turns);

  @override
  Widget build(BuildContext context) {
    final double turnsValue = turns.value;
    Matrix4 transformAnimating;
    if(isShowing && turnsValue >= 0.5 || !isShowing && turnsValue >= 0.5){
      transformAnimating = Matrix4.rotationY((1 - turnsValue)* math.pi);

      //DEBUG
      //print("Key: ${this.child.key} --- isShowing: $isShowing");
    } else {
      transformAnimating = Matrix4.rotationY(math.pi * 0.5);
    }

    return Transform(
      transform: transformAnimating,
      alignment: alignment,
      child: child,
    );
  }
}
