import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({
    super.key,
    required this.radius,
    required this.isViewOnly,
    this.authProvider,
    this.organisationProvider,
    required this.onPressed,
    this.avatarPadding = 8.0,
  });
  final double radius;
  final bool isViewOnly;
  final AuthProvider? authProvider;
  final OrganisationProvider? organisationProvider;
  final VoidCallback onPressed;
  final double avatarPadding;

  @override
  Widget build(BuildContext context) {
    final provider = getProvider();

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(avatarPadding),
          child: CircleAvatar(
              key: UniqueKey(),
              radius: radius,
              backgroundImage: getImageToShow(provider)),
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

  getProvider() {
    if (organisationProvider != null) {
      return organisationProvider;
    } else if (authProvider != null) {
      return authProvider;
    } else {
      throw Exception("No provider found");
    }
  }

  getImageToShow(provider) {
    // check what provider we are using
    bool isAuthProvider = provider == authProvider;

    if (isAuthProvider) {
      if (provider.finalFileImage != null) {
        return FileImage(File(provider.finalFileImage!.path))
            as ImageProvider<Object>;
      } else if (provider.userModel != null &&
          provider.userModel!.imageUrl.isNotEmpty) {
        return CachedNetworkImageProvider(
          provider.userModel!.imageUrl,
          cacheManager: MyImageCacheManager.profileCacheManager,
        );
      } else {
        return AssetImage(AssetsManager.userIcon);
      }
    } else {
      if (provider.finalFileImage != null) {
        return FileImage(File(provider.finalFileImage!.path))
            as ImageProvider<Object>;
      } else if (provider.organisationModel != null &&
          provider.organisationModel!.imageUrl.isNotEmpty) {
        return CachedNetworkImageProvider(
          provider.organisationModel!.imageUrl,
          cacheManager: MyImageCacheManager.profileCacheManager,
        );
      } else {
        return AssetImage(AssetsManager.userIcon);
      }
    }
  }
}
