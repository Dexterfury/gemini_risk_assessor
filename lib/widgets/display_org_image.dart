import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:gemini_risk_assessor/widgets/add_image.dart';

class DisplayOrgImage extends StatelessWidget {
  const DisplayOrgImage({
    super.key,
    required this.isViewOnly,
    required this.organisationProvider,
    required this.onPressed,
  });

  final bool isViewOnly;
  final OrganisationProvider organisationProvider;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 130,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: showOrganisationImage(organisationProvider),
      ),
    );
  }

  Widget showOrganisationImage(organisationProvider) {
    if (organisationProvider.finalFileImage != null) {
      return Image.file(
        File(organisationProvider.finalFileImage!.path),
        fit: BoxFit.cover,
      );
    } else if (organisationProvider.organisationModel != null &&
        organisationProvider.organisationModel!.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: organisationProvider.organisationModel!.imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Center(
            child: Icon(
          Icons.error,
          color: Colors.red,
        )),
        cacheManager: MyImageCacheManager.itemsCacheManager,
      );
    } else {
      return AddImage(
        onTap: onPressed,
      );
    }
  }
}
