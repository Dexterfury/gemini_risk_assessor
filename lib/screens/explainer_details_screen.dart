import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/images_display.dart';
import '../appBars/my_app_bar.dart';

class ExplainerDetailsScreen extends StatelessWidget {
  ExplainerDetailsScreen({
    super.key,
  }) : _scrollController = ScrollController();

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

    return Scaffold(
      appBar: MyAppBar(
        title: title,
        leading: BackButton(
          onPressed: () {
            // pop the screen with save as false
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  icon: Icons.save,
                  label: "Save",
                  onTap: () async {
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
                    // save tool to firestore
                    await toolProvider.saveToolToFirestore().whenComplete(() {
                      // pop the loading dialog
                      Navigator.pop(context);

                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.pop(context); // pop the current screen
                      }); // delay for better UI experience
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
