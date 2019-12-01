import 'package:flutter/material.dart';
import 'package:mobile_application/widgets/general/image_wrapper.dart';

class CircularButton extends StatelessWidget {
  final String assetPath;
  final String imageUrl;
  final double width;
  final double height;
  final Alignment alignment;
  final Function onPressFunction;
  final bool applyElevation;

  CircularButton({
    @required this.assetPath,
    @required this.onPressFunction,
    @required this.alignment,
    this.applyElevation = true,
    this.imageUrl,
    this.width = 40,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: Container(
        width: width,
        height: height,
        child: Stack(
          alignment: alignment,
          children: <Widget>[
            if (applyElevation)
              Container(
                alignment: alignment,
                child: Material(
                  color: Colors.transparent,
                  elevation: 8,
                  shape: const CircleBorder(),
                  child: Container(),
                ),
              ),
            Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.all(const Radius.circular(100)),
                child: ImageWrapper(
                  imageUrl: imageUrl,
                  assetPath: assetPath,
                ),
              ),
            ),
            Container(
              child: RawMaterialButton(
                shape: const CircleBorder(),
                onPressed: onPressFunction,
                child: Container(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
