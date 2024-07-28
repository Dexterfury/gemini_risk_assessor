import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class DisplayGroupImage extends StatelessWidget {
  const DisplayGroupImage({
    Key? key,
    this.isViewOnly = false,
    this.fileImage,
    this.imageUrl = '',
    required this.onPressed,
  }) : super(key: key);

  final bool isViewOnly;
  final File? fileImage;
  final String imageUrl;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
}
