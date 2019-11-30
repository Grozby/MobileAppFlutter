import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageWrapper extends StatelessWidget {
  final String imageUrl;
  final String assetPath;

  ImageWrapper({
    @required this.imageUrl,
    @required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? Image.asset(
            assetPath,
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
              child: FractionallySizedBox(
                  widthFactor: 0.8,
                  heightFactor: 0.8,
                  child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Image.asset(
              "assets/images/" + assetPath,
              fit: BoxFit.cover,
            ),
          );
  }
}
