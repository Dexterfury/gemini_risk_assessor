import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:provider/provider.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({
    super.key,
    required this.radius,
    required this.isViewOnly,
    required this.onPressed,
    this.avatarPadding = 8.0,
  });
  final double radius;
  final bool isViewOnly;
  final VoidCallback onPressed;
  final double avatarPadding;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(avatarPadding),
          child: CircleAvatar(
              key: UniqueKey(),
              radius: radius,
              backgroundImage: getImageToShow(authProvider)),
        ),
        isViewOnly
            ? const SizedBox()
            : Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: onPressed,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  getImageToShow(AuthProvider authProvider) {
    if (authProvider.finalFileImage != null) {
      return FileImage(File(authProvider.finalFileImage!.path))
          as ImageProvider<Object>;
    } else if (authProvider.userModel != null &&
        authProvider.userModel!.imageUrl.isNotEmpty) {
      return CachedNetworkImageProvider(
        authProvider.userModel!.imageUrl,
        cacheManager: MyImageCacheManager.profileCacheManager,
      );

      //NetworkImage(authProvider.userModel!.imageUrl);
    } else {
      return AssetImage(AssetsManager.userIcon);
    }

    // if (authProvider.userModel != null) {
    //   if (authProvider.userModel!.imageUrl.isNotEmpty) {
    //     return NetworkImage(authProvider.userModel!.imageUrl);
    //   } else if (authProvider.finalFileImage != null) {
    //     return FileImage(File(authProvider.finalFileImage!.path))
    //         as ImageProvider;
    //   } else {
    //     AssetImage(AssetsManager.userIcon);
    //   }
    // } else {
    //   if (authProvider.finalFileImage == null) {
    //     return AssetImage(AssetsManager.userIcon);
    //   } else {
    //     return FileImage(File(authProvider.finalFileImage!.path))
    //         as ImageProvider;
    //   }
    // }
  }
}
