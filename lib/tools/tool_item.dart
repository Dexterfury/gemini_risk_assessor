import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/discussions/chat_discussion_screen.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/tools/explainer_details_screen.dart';
import 'package:gemini_risk_assessor/groups/group_list_tile.dart';
import 'package:gemini_risk_assessor/widgets/my_list_tile.dart';
import 'package:provider/provider.dart';

class ToolItem extends StatelessWidget {
  const ToolItem({
    super.key,
    required this.toolModel,
    required this.groupID,
    required this.isAdmin,
  });

  final ToolModel toolModel;
  final String groupID;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final chatProvider = context.read<ChatProvider>();
    String title = toolModel.title;
    String summary = toolModel.summary;
    String imageUrl = toolModel.images[0];

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
                  imageUrl: imageUrl,
                  title: title,
                  summary: summary,
                  onTap: action,
                )
              : StreamBuilder<int>(
                  stream: FirebaseMethods.getMessageCountStream(
                    groupID: groupID,
                    itemID: toolModel.id,
                    generationType: GenerationType.tool,
                  ),
                  builder: (context, snapshot) {
                    final messageCount = snapshot.data ?? 0;
                    return groupListTile(
                      imageUrl: imageUrl,
                      title: title,
                      summary: summary,
                      onTap: action,
                      messageCount: messageCount,
                      onMessageTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDiscussionScreen(
                              groupID: groupID,
                              tool: toolModel,
                              generationType: GenerationType.tool,
                            ),
                          ),
                        );
                      },
                      onGeminiTap: () async {
                        await chatProvider
                            .getChatHistoryFromFirebase(
                                uid: uid,
                                generationType: GenerationType.tool,
                                toolModel: toolModel)
                            .whenComplete(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                toolModel: toolModel,
                                generationType: GenerationType.tool,
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
          return ExplainerDetailsScreen(
            isAdmin: isAdmin,
            groupID: groupID,
            currentModel: toolModel,
          );
        },
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        closedElevation: 0,
        openElevation: 4,
        closedColor: Theme.of(context).cardColor,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
