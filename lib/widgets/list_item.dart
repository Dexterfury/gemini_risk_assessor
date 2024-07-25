import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/groups/group_list_tile.dart';
import 'package:gemini_risk_assessor/widgets/my_list_tile.dart';
import 'package:provider/provider.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.docTitle,
    required this.groupID,
    required this.data,
  });
  final String docTitle;
  final String groupID;
  final AssessmentModel data;

  @override
  Widget build(BuildContext context) {
    // get generationType
    final generationType = getGenerationType(docTitle);
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final chatProvider = context.read<ChatProvider>();
    final image = data.images.isNotEmpty ? data.images.first : '';
    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: OpenContainer(
        closedBuilder: (context, action) {
          return groupID.isEmpty
              ? MyListTile(
                  imageUrl: image,
                  title: data.title,
                  summary: data.summary,
                  onTap: action,
                )
              : StreamBuilder<int>(
                  stream: FirebaseMethods.getMessageCountStream(
                    groupID: groupID,
                    itemID: data.id,
                    generationType: generationType,
                  ),
                  builder: (context, snapshot) {
                    final messageCount = snapshot.data ?? 0;
                    return groupListTile(
                      imageUrl: image,
                      title: data.title,
                      summary: data.summary,
                      onTap: action,
                      messageCount: messageCount,
                      onMessageTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDiscussionScreen(
                              groupID: groupID,
                              assessment: data,
                              generationType: generationType,
                            ),
                          ),
                        );
                      },
                      onGeminiTap: () async {
                        await chatProvider
                            .getChatHistoryFromFirebase(
                          uid: uid,
                          generationType: generationType,
                          assessmentModel: data,
                        )
                            .whenComplete(() {
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
                  },
                );
        },
        openBuilder: (context, action) {
          return AssessmentDetailsScreen(
            appBarTitle: docTitle,
            groupID: groupID,
            currentModel: data,
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
