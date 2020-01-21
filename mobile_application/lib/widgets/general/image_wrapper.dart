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
            width: double.infinity,
            height: double.infinity,
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

extension AssetImages on ImageWrapper {
  static const String WORK = "job_128.png";
  static const String EDUCATION = "degree_128.png";

  static const String USER = "user.png";
  static const String BACK_ARROW = "back_arrow.png";
  static const String MESSAGE = "message.png";
  static const String SETTINGS = "settings.png";

  static String socialAssets(String social) => social + ".png";

  static const String DELETE = "ic_delete.png";
  static const String LOGO = "logo.png";
}