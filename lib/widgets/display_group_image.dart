import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class DisplayGroupImage extends StatelessWidget {
  const DisplayGroupImage({
    super.key,
    this.isViewOnly = false,
    this.fileImage,
    this.imageUrl = '',
    required this.onPressed,
  });

  final bool isViewOnly;
  final File? fileImage;
  final String imageUrl;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 130,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GestureDetector(
          onTap: onPressed,
          child: MyImageCacheManager.showImage(
            fileImage: fileImage,
            imageUrl: imageUrl,
            isTool: false,
            isCreation: true,
          ),
        ),
      ),
    );
  }

  // Widget showGroupImage(
  //   File? fileImage,
  //   String imageUrl,
  // ) {
  //   if (fileImage != null) {
  //     return Image.file(
  //       File(fileImage.path),
  //       fit: BoxFit.cover,
  //     );
  //   } else if (imageUrl.isNotEmpty) {
  //     return CachedNetworkImage(
  //       imageUrl: imageUrl,
  //       fit: BoxFit.cover,
  //       placeholder: (context, url) =>
  //           const Center(child: CircularProgressIndicator()),
  //       errorWidget: (context, url, error) => const Center(
  //           child: Icon(
  //         Icons.error,
  //         color: Colors.red,
  //       )),
  //       cacheManager: MyImageCacheManager.itemsCacheManager,
  //     );
  //   } else {
  //     return
  //   }
  // }
}
