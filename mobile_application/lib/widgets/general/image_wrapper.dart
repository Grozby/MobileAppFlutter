import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageWrapper extends StatelessWidget {
  final String imageUrl;
  final String assetPath;
  final BoxFit boxFit;

  ImageWrapper({
    @required this.assetPath,
    this.imageUrl,
    this.boxFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? Image.asset(
            "assets/images/" + assetPath,
            fit: boxFit,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fadeInDuration: const Duration(milliseconds: 500),
            fit: boxFit,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              "assets/images/" + assetPath,
              fit: boxFit,
            ),
          );
  }
}
