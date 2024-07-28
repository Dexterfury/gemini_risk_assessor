import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';

class MyImageCacheManager {
  static CacheManager profileCacheManager = CacheManager(
    Config(Constants.userImageKey,
        maxNrOfCacheObjects: 20, stalePeriod: const Duration(days: 5)),
  );

  static CacheManager itemsCacheManager = CacheManager(
    Config(Constants.generatedImagesKey,
        maxNrOfCacheObjects: 100, stalePeriod: const Duration(days: 5)),
  );

  static Widget showImage({
    File? fileImage,
    required String imageUrl,
    required bool isTool,
    bool isCreation = false,
  }) {
    if (fileImage != null) {
      return Image.file(
        File(fileImage.path),
        fit: BoxFit.cover,
      );
    } else if (imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Center(
            child: Icon(
          Icons.error,
          color: Colors.red,
        )),
        cacheManager: itemsCacheManager,
      );
    } else {
      if (isTool) {
        return Image.asset(
          AssetsManager.toolsIcon,
          fit: BoxFit.cover,
        );
      } else {
        if (isCreation) {
          return SizedBox(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                  ),
                ),
              ),
            ),
          );
        }
        return Image.asset(
          AssetsManager.groupIcon,
          fit: BoxFit.cover,
        );
      }
    }
  }
}
