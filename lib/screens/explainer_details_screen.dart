import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/images_display.dart';
import '../widgets/my_app_bar.dart';

class ExplainerDetailsScreen extends StatelessWidget {
  ExplainerDetailsScreen({
    super.key,
    required this.animation,
  }) : _scrollController = ScrollController();

  final Animation<double> animation;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    // toolProvider
    final toolProvider = context.watch<ToolsProvider>();
    // time
    final time = toolProvider.toolModel!.createdAt;
    // title
    final title = toolProvider.toolModel!.name;
    // Format the datetime using Intl package
    String formattedTime = DateFormat.yMMMEd().format(time);

    return SafeArea(
      child: ScaleTransition(
        scale: Tween(begin: 3.0, end: 1.0).animate(animation),
        child: Scaffold(
          appBar: MyAppBar(
            title: title,
            leading: BackButton(
              onPressed: () {
                // pop the screen with save as false
                Navigator.of(context).pop(false);
              },
            ),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImagesDisplay(
                  isViewOnly: true,
                  toolProvider: toolProvider,
                ),
                const SizedBox(
                  height: 10,
                ),

                // descpription
                Text(
                  toolProvider.toolModel!.description,
                  style: textStyle16w600,
                ),
                const SizedBox(
                  height: 20,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: MainAppButton(
                    widget: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    label: "Save",
                    onTap: () async {
                      // show my alert dialog for loading
                      showMyAnimatedDialog(
                        context: context,
                        title: 'Saving',
                        content: 'Please wait...',
                        loadingIndicator: const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator()),
                      );
                      // save tool to firestore
                      await toolProvider.saveToolToFirestore().whenComplete(() {
                        // pop the loading dialog
                        Navigator.pop(context);

                        // pop the screen with save as true
                        Navigator.of(context).pop(true);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
