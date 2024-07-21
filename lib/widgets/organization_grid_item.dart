import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/screens/organization_details.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class OrganizationGridItem extends StatelessWidget {
  const OrganizationGridItem({
    super.key,
    required this.orgModel,
  });

  final OrganizationModel orgModel;

  @override
  Widget build(BuildContext context) {
    String title = orgModel.name;
    String subtitle = orgModel.aboutOrganization;
    String imageUrl = orgModel.imageUrl!;
    ;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxHeight * 0.8;
          final textHeight = constraints.maxHeight * 0.2;
          try {
            return OpenContainer(
              closedBuilder: (context, action) => InkWell(
                onTap: action,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: constraints.maxWidth,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: MyImageCacheManager.showImage(
                          imageUrl: imageUrl,
                          isTool: false,
                        ),
                      ),
                    ),
                    SizedBox(height: textHeight * 0.1),
                    SizedBox(
                      height: textHeight * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          title,
                          style: textStyle16w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              openBuilder: (context, action) {
                return OrganizationDetails(
                  orgModel: orgModel,
                );
              },
              transitionType: ContainerTransitionType.fadeThrough,
              transitionDuration: const Duration(milliseconds: 500),
              closedElevation: 0,
              openElevation: 4,
              closedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              openShape: const RoundedRectangleBorder(),
            );
          } catch (e, stackTrace) {
            print('Error in OpenContainer: $e');
            print('Stack trace: $stackTrace');
            // Return a fallback widget
            return Card(child: Text(title));
          }
        },
      ),
    );
  }
}
