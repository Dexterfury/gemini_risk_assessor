import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/animated_chat_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/chat_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
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
    final toolProvider = getProvider(
      context,
      currentModel,
    );

    final toolModel = getModel(
      context,
      currentModel,
    );
    // title
    final title = toolModel!.name;
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
                  child: AnimatedChatButton(
                    onPressed: () async {
                      // Open chat or navigate to chat screen
                      // Open chat or navigate to chat screen
                      final uid = context.read<AuthProvider>().userModel!.uid;
                      final chatProvider = context.read<ChatProvider>();
                      await chatProvider
                          .getChatHistoryFromFirebase(
                        uid: uid,
                        toolModel: toolModel,
                      )
                          .whenComplete(() {
                        // Navigate to the chat screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              toolModel: toolModel,
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
                      content: 'Please wait...',
                      loadingIndicator: const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator()),
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
                style: textStyle16w600,
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  getProvider(
    BuildContext context,
    ToolModel? currentModel,
  ) {
    if (currentModel != null) {
      return null;
    } else {
      return context.watch<ToolsProvider>();
    }
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
