import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/tools/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/screens/share_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/images_display.dart';
import '../appBars/my_app_bar.dart';

class ExplainerDetailsScreen extends StatelessWidget {
  ExplainerDetailsScreen({
    super.key,
    this.currentModel,
    this.onSave,
  }) : _scrollController = ScrollController();

  final ToolModel? currentModel;
  final Function(bool)? onSave;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    // toolProvider
    final toolProvider = context.read<ToolsProvider>();

    final toolModel = getModel(
      context,
      currentModel,
    );
    // title
    final title = toolModel!.title;
    // description
    final description = toolModel!.description;

    return Scaffold(
      appBar: MyAppBar(
        title: 'Details',
        leading: const BackButton(),
        actions: [
          currentModel != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GeminiFloatingChatButton(
                    onPressed: () async {
                      // Open chat or navigate to chat screen
                      // Open chat or navigate to chat screen
                      final uid =
                          context.read<AuthenticationProvider>().userModel!.uid;
                      final chatProvider = context.read<ChatProvider>();
                      await chatProvider
                          .getChatHistoryFromFirebase(
                              uid: uid,
                              toolModel: toolModel,
                              generationType: GenerationType.tool)
                          .whenComplete(() {
                        // Navigate to the chat screen
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
                    size: ChatButtonSize.small,
                    iconColor: Colors.white,
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    // show my alert dialog for loading
                    MyDialogs.showMyAnimatedDialog(
                      context: context,
                      title: 'Saving',
                      loadingIndicator: const SizedBox(
                        height: 100,
                        width: 100,
                        child: LoadingPPEIcons(),
                      ),
                    );
                    bool success = await toolProvider.saveToolToFirestore();
                    Future.delayed(const Duration(milliseconds: 200))
                        .whenComplete(() async {
                      Navigator.pop(context); // Pop the loading dialog
                      await Future.delayed(const Duration(milliseconds: 500))
                          .whenComplete(() {
                        Navigator.pop(context); // pop the screen
                        if (onSave != null) {
                          onSave!(success);
                        }
                      });
                    });
                  },
                  icon: const Icon(
                    FontAwesomeIcons.floppyDisk,
                  ),
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ImagesDisplay(
                isViewOnly: true,
                toolProvider: toolProvider,
                currentToolModel: currentModel,
              ),
              const SizedBox(
                height: 10,
              ),

              // descpription
              Text(
                description,
                style: AppTheme.textStyle16w600,
              ),
              const SizedBox(
                height: 20,
              ),
              currentModel != null
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: OpenContainer(
                        closedBuilder: (context, action) {
                          return IconButton(
                            onPressed: action,
                            icon: const Icon(
                              FontAwesomeIcons.share,
                            ),
                          );
                        },
                        openBuilder: (context, action) {
                          // navigate to screen depending on the clicked icon
                          return ShareScreen(
                            toolModel: currentModel,
                            generationType: GenerationType.tool,
                          );
                        },
                        transitionType: ContainerTransitionType.fadeThrough,
                        transitionDuration: const Duration(milliseconds: 500),
                        closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        closedElevation: 4,
                        openElevation: 4,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  getModel(
    BuildContext context,
    ToolModel? currentModel,
  ) {
    if (currentModel != null) {
      return currentModel;
    } else {
      final toolProvider = context.watch<ToolsProvider>();
      return toolProvider.toolModel;
    }
  }
}
