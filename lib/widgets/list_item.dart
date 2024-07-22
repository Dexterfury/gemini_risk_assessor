import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:gemini_risk_assessor/widgets/enhanced_list_tile.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.docTitle,
    required this.orgID,
    required this.data,
    required this.isDiscussion,
  });
  final String docTitle;
  final String orgID;
  final AssessmentModel data;
  final bool isDiscussion;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: OpenContainer(
        closedBuilder: (context, action) {
          return EnhancedListTile(
            imageUrl: data.images.first,
            title: data.title,
            summary: data.summary,
            onTap: action,
            messageCount: 5, // Replace with actual count
            likeCount: 10, // Replace with actual count
            onMessageTap: () {
              // Handle message tap
            },
            onLikeTap: () {
              // Handle like tap
            },
          );

          // ListTile(
          //   contentPadding: const EdgeInsets.only(left: 8.0, right: 8.0),
          //   leading: SizedBox(
          //     width: 80,
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(10),
          //       child: CachedNetworkImage(
          //         imageUrl: data.images.first,
          //         fit: BoxFit.cover,
          //         placeholder: (context, url) =>
          //             const Center(child: CircularProgressIndicator()),
          //         errorWidget: (context, url, error) => const Center(
          //             child: Icon(
          //           Icons.error,
          //           color: Colors.red,
          //         )),
          //         cacheManager: MyImageCacheManager.itemsCacheManager,
          //       ),
          //     ),
          //   ),
          //   title: Text(
          //     data.title,
          //     maxLines: 1,
          //     overflow: TextOverflow.ellipsis,
          //   ),
          //   subtitle: Text(
          //     data.summary,
          //     maxLines: 2,
          //     overflow: TextOverflow.ellipsis,
          //   ),
          //   onTap: action,
          // );
        },
        openBuilder: (context, action) {
          if (isDiscussion) {
            // get generationType
            final generationType = getGenerationType(docTitle);
            return ChatDiscussionScreen(
              assessment: data,
              generationType: generationType,
            );
          } else {
            return AssessmentDetailsScreen(
              appBarTitle: docTitle,
              orgID: orgID,
              currentModel: data,
            );
          }
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
