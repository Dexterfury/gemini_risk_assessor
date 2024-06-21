import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/explainer_details_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../providers/auth_provider.dart';

class CreateExplainerScreen extends StatefulWidget {
  const CreateExplainerScreen({super.key});

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
    if (provider.isViewOnly) {
      return provider.toolModel!.images;
    }
    return provider.imagesFileList!;
  }

  @override
  Widget build(BuildContext context) {
    final toolProvider = context.watch<ToolsProvider>();
    final images = _getImages(toolProvider);
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: MyAppBar(
        leading: backIcon(context: context),
        title: 'Tool Explainer',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.60,
              width: MediaQuery.of(context).size.width,
              child: previewImages(
                context: context,
                images: images,
                pageController: _pageController,
                isViewOnly: toolProvider.isViewOnly,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            PageIndicator(
              pageController: _pageController,
              images: images,
            ),
            const SizedBox(
              height: 10,
            ),
            toolProvider.isViewOnly
                ? buildToolDescriptionText(toolProvider)
                : buildInputGenerationBtn(toolProvider, context),
          ],
        ),
      ),
    );
  }

  buildInputGenerationBtn(ToolsProvider toolProvider, BuildContext context) {
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
            child: MainAppButton(
              widget: const Icon(
                Icons.create,
                color: Colors.white,
              ),
              label: 'Generate Explainer',
              onTap: () async {
                //check if images are added
                if (toolProvider.imagesFileList!.isEmpty) {
                  showSnackBar(context: context, message: 'Please add images');
                  return;
                }

                await toolProvider.windowstestPrompt();
                if (!context.mounted) return;
                // display the results
                if (toolProvider.toolModel != null) {
                  // display the risk assessment details screen
                  PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
                    opaque: false,
                    pageBuilder:
                        (BuildContext context, animation, secondaryAnimation) =>
                            ExplainerDetailsScreen(
                      animation: animation,
                    ),
                  );
                  bool saved =
                      await Navigator.of(context).push(pageRouteBuilder);
                  if (saved) {
                    // reset the data
                    toolProvider.resetPromptData();

                    setState(() {
                      _descriptionController.clear();
                    });
                    Future.delayed(const Duration(milliseconds: 200))
                        .whenComplete(() {
                      showSnackBar(
                          context: context, message: 'Tool successfully saved');
                    });
                  }
                }

                // show my alert dialog for loading
                // showMyAnimatedDialog(
                //   context: context,
                //   title: 'Generating',
                //   content: 'Please wait...',
                //   loadingIndicator: const SizedBox(
                //       height: 40,
                //       width: 40,
                //       child: CircularProgressIndicator()),
                // );

                // final authProvider = context.read<AuthProvider>();
                // final description = _descriptionController.text;

                // await toolProvider
                //     .submitPrompt(
                //   creatorID: authProvider.userModel!.uid,
                //   description: description,
                // )
                //     .then((_) async {
                //   // hide my alert dialog
                //   Navigator.pop(context);

                //   if (!context.mounted) return;
                //   // display the results
                //   if (toolProvider.toolModel != null) {
                //     // display the risk assessment details screen
                //     PageRouteBuilder pageRouteBuilder =
                //         PageRouteBuilder(
                //       opaque: false,
                //       pageBuilder: (BuildContext context, animation,
                //               secondaryAnimation) =>
                //           ExplainerDetailsScreen(
                //         animation: animation,
                //       ),
                //     );
                //     bool shouldSave = await Navigator.of(context)
                //         .push(pageRouteBuilder);
                //     if (shouldSave) {
                //       // TODO save the risk assessment to database
                //     }
                //   }
                // });
              },
            ),
          ),
        ],
      ),
    );
  }

  buildToolDescriptionText(ToolsProvider toolProvider) {
    return Text(
      toolProvider.toolModel!.description,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required PageController pageController,
    required this.images,
  }) : _pageController = pageController;

  final PageController _pageController;
  final List<dynamic> images;

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: images.length,
              effect: const WormEffect(
                dotHeight: 16,
                dotWidth: 16,
                type: WormType.normal,
              ),
            ),
          );
  }
}
