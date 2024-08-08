import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/groups/group_list_tile.dart';
import 'package:gemini_risk_assessor/widgets/my_list_tile.dart';
import 'package:provider/provider.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.docTitle,
    required this.groupID,
    required this.data,
    required this.isAdmin,
  });
  final String docTitle;
  final String groupID;
  final AssessmentModel data;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    // get generationType
    final generationType = GenerationType.riskAssessment;
    ;
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final chatProvider = context.read<ChatProvider>();
    final image = data.images.isNotEmpty ? data.images.first : '';
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
          ),
        ),
      ),
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
            isAdmin: isAdmin,
          );
        },
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        closedElevation: 0,
        openElevation: 4,
        closedColor: Theme.of(context).cardColor,
        // closedShape: RoundedRectangleBorder(
        //   //borderRadius: BorderRadius.circular(10),
        // ),
      ),
    );
  }
}
