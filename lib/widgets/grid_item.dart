import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/screens/tool_chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/screens/explainer_details_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class ToolGridItem extends StatelessWidget {
  const ToolGridItem({
    super.key,
    required this.toolModel,
  });

  final ToolModel toolModel;

  @override
  Widget build(BuildContext context) {
    String title = toolModel.title;
    //String subtitle = toolModel.summary;
    String imageUrl = toolModel.images[0];

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
                        isTool: true,
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
              return ExplainerDetailsScreen(
                currentModel: toolModel,
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
        },
      ),
    );
  }
}
