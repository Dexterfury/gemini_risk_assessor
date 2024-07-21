import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/screens/chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/screens/explainer_details_screen.dart';
import 'package:gemini_risk_assessor/screens/organization_details.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class GridItem extends StatelessWidget {
  const GridItem({
    super.key,
    this.toolModel,
    this.orgModel,
    required this.isDiscussion,
  });

  final ToolModel? toolModel;
  final OrganizationModel? orgModel;
  final bool isDiscussion;

  @override
  Widget build(BuildContext context) {
    // Check if both models are null
    if (toolModel == null && orgModel == null) {
      return const Card(
        child: Center(child: Text('No data available')),
      );
    }

    // get title and subtitle based on model type
    bool isTool = toolModel != null;
    String title = getTitle();
    String subtitle = getSubTitle();
    String imageUrl = getImageUrl();

    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
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
                    width: constraints.maxWidth,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: MyImageCacheManager.showImage(
                        imageUrl: imageUrl,
                        isTool: isTool,
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
              if (isDiscussion) {
                return ChatDiscussionScreen(
                  orgID: orgModel?.organizationID ?? '',
                  toolModel: toolModel,
                );
              } else {
                if (isTool && toolModel != null) {
                  return ExplainerDetailsScreen(
                    currentModel: toolModel!,
                  );
                } else if (orgModel != null) {
                  return OrganizationDetails(
                    orgModel: orgModel!,
                  );
                } else {
                  // Fallback in case neither model is available
                  return const Scaffold(
                    body: Center(child: Text('No data available')),
                  );
                }
              }
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
        },
      ),
    );
  }

  String getTitle() {
    if (toolModel != null) {
      return toolModel!.title;
    } else if (orgModel != null) {
      return orgModel!.name;
    } else {
      return "No title";
    }
  }

  String getSubTitle() {
    if (toolModel != null) {
      return toolModel!.summary;
    } else if (orgModel != null) {
      return orgModel!.aboutOrganization;
    } else {
      return "No subtitle";
    }
  }

  String getImageUrl() {
    if (toolModel != null && toolModel!.images.isNotEmpty) {
      return toolModel!.images[0];
    } else if (orgModel != null && orgModel!.imageUrl != null) {
      return orgModel!.imageUrl!;
    } else {
      return "No image";
    }
  }
}
