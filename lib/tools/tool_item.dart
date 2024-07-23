import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/tools/explainer_details_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/enhanced_list_tile.dart';

class ToolItem extends StatelessWidget {
  const ToolItem({
    super.key,
    required this.toolModel,
    required this.groupID,
  });

  final ToolModel toolModel;
  final String groupID;

  @override
  Widget build(BuildContext context) {
    String title = toolModel.title;
    String subtitle = toolModel.summary;
    String imageUrl = toolModel.images[0];

    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: OpenContainer(
        closedBuilder: (context, action) {
          return EnhancedListTile(
            imageUrl: imageUrl,
            title: title,
            summary: subtitle,
            onTap: action,
            messageCount: 5, // Replace with actual count
            isGroup: groupID.isNotEmpty,
            onMessageTap: () {
              // Handle message tap
              // Navigate to the chat screen
            },
            onGeminiTap: () async {
              // handle gemini tap
            },
          );
        },
        openBuilder: (context, action) {
          return ExplainerDetailsScreen(
            currentModel: toolModel,
          );
        },
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        closedElevation: 0,
        openElevation: 4,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
