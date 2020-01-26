import 'package:flutter/material.dart';

import '../../general/image_wrapper.dart';

class CircularButton extends StatelessWidget {
  final String assetPath;
  final String imageUrl;
  final double width;
  final double height;
  final double reduceFactor;
  final Alignment alignment;
  final void Function() onPressFunction;

  CircularButton({
    @required this.assetPath,
    @required this.onPressFunction,
    @required this.alignment,
    this.reduceFactor = 0.8,
    this.imageUrl,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: InkWell(
        customBorder: CircleBorder(),
        onTap: onPressFunction,
        child: Container(
          width: width,
          height: height,
          child: FractionallySizedBox(
            heightFactor: reduceFactor,
            widthFactor: reduceFactor,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              child: ImageWrapper(
                imageUrl: imageUrl,
                assetPath: assetPath,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
