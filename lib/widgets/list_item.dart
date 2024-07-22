import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/enhanced_list_tile.dart';
import 'package:provider/provider.dart';

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
    // get generationType
    final generationType = getGenerationType(docTitle);
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final chatProvider = context.read<ChatProvider>();
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
              // Navigate to the chat screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDiscussionScreen(
                    orgID: orgID,
                    assessment: data,
                    generationType: generationType,
                  ),
                ),
              );
            },
            onGeminiTap: () async {
              // handle gemini tap
              await chatProvider
                  .getChatHistoryFromFirebase(
                uid: uid,
                generationType: generationType,
                assessmentModel: data,
              )
                  .whenComplete(() {
                // Navigate to the chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      assessmentModel: data,
                      generationType: generationType,
                    ),
                  ),
                );
              });
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
            return ChatDiscussionScreen(
              orgID: orgID,
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
