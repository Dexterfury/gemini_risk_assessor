import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/explainer_details_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/page_indicator.dart';
import 'package:provider/provider.dart';

class CreateExplainerScreen extends StatefulWidget {
  const CreateExplainerScreen({
    super.key,
    this.tool,
  });

  final ToolModel? tool;

  @override
  State<CreateExplainerScreen> createState() => _CreateExplainerScreenState();
}

class _CreateExplainerScreenState extends State<CreateExplainerScreen> {
  // description controller
  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();
  //PageController(viewportFraction: 0.8, keepPage: true);

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  _getImages(ToolsProvider provider) {
    if (widget.tool != null) {
      return widget.tool!.images;
    }
    return provider.imagesFileList!;
  }

  @override
  Widget build(BuildContext context) {
    // get the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final title = args[Constants.title] as String;
    final orgID = args[Constants.orgArg] as String;
    final toolProvider = context.watch<ToolsProvider>();
    final images = _getImages(toolProvider);
    final bool isViewOnly = widget.tool != null;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: MyAppBar(
        leading: const BackButton(),
        title: title,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.60,
                width: MediaQuery.of(context).size.width,
                child: previewImages(
                  context: context,
                  images: images,
                  pageController: _pageController,
                  isViewOnly: isViewOnly,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              PageIndicator(
                pageController: _pageController,
                images: images,
              ),
              const SizedBox(
                height: 4,
              ),
              isViewOnly
                  ? buildToolDescriptionText(widget.tool!)
                  : buildInputGenerationBtn(
                      toolProvider,
                      context,
                      orgID,
                    ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildInputGenerationBtn(
    ToolsProvider toolProvider,
    BuildContext context,
    String orgID,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          InputField(
            labelText: 'Enter description [optional]',
            hintText: 'Description',
            controller: _descriptionController,
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OpenContainer(
              closedBuilder: (context, action) {
                return MainAppButton(
                  icon: FontAwesomeIcons.wandMagicSparkles,
                  label: 'Generate Explainer',
                  onTap: () async {
                    //check if images are added
                    if (toolProvider.imagesFileList!.isEmpty) {
                      showSnackBar(
                          context: context, message: 'Please add images');
                      return;
                    }

                    // show my alert dialog for loading
                    MyDialogs.showMyAnimatedDialog(
                      context: context,
                      title: 'Generating',
                      content: 'Please wait...',
                      loadingIndicator: const SizedBox(
                        height: 100,
                        width: 100,
                        child: LoadingPPEIcons(),
                      ),
                    );

                    final authProvider = context.read<AuthenticationProvider>();
                    final description = _descriptionController.text;

                    await toolProvider.submitPrompt(
                      creatorID: authProvider.userModel!.uid,
                      organizationID: orgID,
                      description: description,
                      onSuccess: () {
                        // pop the loading dialog
                        Navigator.pop(context);
                        Future.delayed(const Duration(milliseconds: 500))
                            .whenComplete(action);
                      },
                      onError: (error) {
                        showSnackBar(
                          context: context,
                          message: error,
                        );
                      },
                    );
                  },
                );
              },
              openBuilder: (context, action) {
                // navigate to details screen
                return ExplainerDetailsScreen(
                  onSave: (value) {
                    if (value) {
                      // clear data
                      toolProvider.clearImages();
                      _descriptionController.clear();

                      showSnackBar(
                          context: context, message: 'Tool Successfully saved');
                    } else {
                      showSnackBar(
                          context: context, message: 'Error saving tool');
                    }
                  },
                );
              },
              transitionType: ContainerTransitionType.fadeThrough,
              transitionDuration: const Duration(milliseconds: 500),
              closedElevation: 0,
              openElevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  buildToolDescriptionText(ToolModel tool) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tool.title,
            style: textStyle18w500,
          ),
          const SizedBox(height: 10),
          Text(
            tool.description,
            style: textStyle18w500,
          ),
        ],
      ),
    );
  }
}
