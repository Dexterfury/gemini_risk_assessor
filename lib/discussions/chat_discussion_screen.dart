import 'package:flutter/material.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:gemini_risk_assessor/app_bars/discussion_app_bar.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/discussions/chat_list.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_field.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/service/gemini_actions.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:provider/provider.dart';

class ChatDiscussionScreen extends StatefulWidget {
  const ChatDiscussionScreen({
    super.key,
    required this.groupID,
    this.assessment,
    this.tool,
    required this.generationType,
  });
  final String groupID;
  final AssessmentModel? assessment;
  final ToolModel? tool;
  final GenerationType generationType;

  @override
  State<ChatDiscussionScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatDiscussionScreen> {
  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Chat Discussion Scree',
      screenClass: 'ChatDiscussionScreen',
    );
    super.initState();
  }

  void showGeminiActions() async {
    final currentUID =
        await context.read<AuthenticationProvider>().userModel!.uid;
    bool isAdmin =
        await FirebaseMethods.checkIsAdmin(widget.groupID, currentUID);
    Navigator.of(context).push(
      HeroDialogRoute(builder: (context) {
        return GeminiActions(
          isAdmin: isAdmin,
          assessment: widget.assessment,
          tool: widget.tool,
          groupID: widget.groupID,
          generationType: widget.generationType,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle =
        widget.tool != null ? widget.tool!.title : widget.assessment!.title;
    final appBarSubtitle =
        widget.tool != null ? widget.tool!.summary : widget.assessment!.summary;
    final appBarImage = getImage(widget.tool, widget.assessment);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: DiscussionAppBar(
        title: appBarTitle,
        subtitle: appBarSubtitle,
        imageUrl: appBarImage,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GeminiFloatingChatButton(
              onPressed: showGeminiActions,
              size: ChatButtonSize.small,
              iconColor: Colors.white,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Column(
            children: [
              Expanded(
                child: ChatList(
                  groupID: widget.groupID,
                  assessment: widget.assessment,
                  tool: widget.tool,
                  generationType: widget.generationType,
                ),
              ),
              DiscussionChatField(
                groupID: widget.groupID,
                assessment: widget.assessment,
                tool: widget.tool,
                generationType: widget.generationType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

getImage(ToolModel? tool, AssessmentModel? assessment) {
  if (tool != null && tool.images.isNotEmpty) {
    return tool.images[0];
  } else if (assessment != null && assessment.images.isNotEmpty) {
    return assessment
        .images[0]; // Assuming images are stored in the AssessmentModel
  } else {
    return ''; // Return empty string if no image is found
  }
}
