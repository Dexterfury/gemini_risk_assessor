import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/screens/create_organisation_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class OrgGridItem extends StatelessWidget {
  const OrgGridItem({super.key, required this.orgModel});

  final OrganisationModel orgModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxHeight * 0.8;
          final textHeight = constraints.maxHeight * 0.2;

          return OpenContainer(
            closedBuilder: (context, action) => InkWell(
              onTap: action,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: orgModel.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                            child: Icon(
                          Icons.error,
                          color: Colors.red,
                        )),
                        cacheManager: MyImageCacheManager.itemsCacheManager,
                      ),

                      // Image.file(
                      //   File(tool.images.first),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  ),
                  SizedBox(
                    height: textHeight * 0.1,
                  ), // Spacing between image and text
                  SizedBox(
                    height: textHeight * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        orgModel.organisationName,
                        style: textStyle16w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            openBuilder: (context, action) => const CreateOrganisationScreen(),
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 500),
            closedElevation: 0,
            openElevation: 4,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            openShape: const RoundedRectangleBorder(),
          );
        },
      ),
    );
  }
}
