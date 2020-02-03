import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/providers/configuration.dart';

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
            "assets/images/$assetPath",
            fit: boxFit,
          )
        : CachedNetworkImage(
            width: double.infinity,
            height: double.infinity,
            imageUrl: imageUrl.contains("http") ? imageUrl : "${Configuration.serverUrl}/$imageUrl",
            fadeInDuration: const Duration(milliseconds: 500),
            fit: boxFit,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => Image.asset(
              "assets/images/$assetPath",
              fit: boxFit,
            ),
          );
  }
}

extension AssetImages on ImageWrapper {
  static const String work = "job_128.png";
  static const String education = "degree_128.png";

  static const String edit = "edit.png";
  static const String camera = "camera.png";
  static const String user = "user.png";
  static const String backArrow = "back_arrow.png";
  static const String message = "message.png";
  static const String settings = "settings.png";

  static String socialAssets(String social) => "$social.png";

  static const String delete = "ic_delete.png";
  static const String logo = "logo.png";

  static const String lightBackground = "light.png";
}
