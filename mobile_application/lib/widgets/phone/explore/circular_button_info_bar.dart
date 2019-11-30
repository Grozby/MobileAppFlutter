import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';

class CircularButtonInfoBar extends StatelessWidget {
  final String assetPath;
  final Function onPressFunction;
  final String imageUrl;

  CircularButtonInfoBar({
    @required this.assetPath,
    @required this.onPressFunction,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.55,
      child: Stack(
        children: <Widget>[
          const Center(
            child: Material(
              color: Colors.transparent,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Center(),
            ),
          ),
          Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(const Radius.circular(100)),
              child: ImageWrapper(
                imageUrl: imageUrl,
                assetPath: assetPath,
              ),
            ),
          ),
          Center(
            child: RawMaterialButton(
              shape: const CircleBorder(),
              onPressed: onPressFunction,
              child: const Center(),
            ),
          )
        ],
      ),
    );
  }
}
