import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageWrapper extends StatelessWidget {
  final String imageUrl;
  final String assetPath;

  ImageWrapper({
    @required this.assetPath,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? Image.asset(
            "assets/images/" + assetPath,
            fit: BoxFit.cover,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fadeInDuration: const Duration(milliseconds: 500),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              "assets/images/" + assetPath,
              fit: BoxFit.cover,
            ),
          );
  }
}
