import 'package:flutter/material.dart';

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
              child: imageUrl == null
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
//
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
