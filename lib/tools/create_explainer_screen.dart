import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/gemini_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/tools/tool_provider.dart';
import 'package:gemini_risk_assessor/tools/explainer_details_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/page_indicator.dart';
import 'package:provider/provider.dart';

class CreateExplainerScreen extends StatefulWidget {
  const CreateExplainerScreen({
    Key? key,
    this.tool,
  }) : super(key: key);

  final ToolModel? tool;

  @override
  State<CreateExplainerScreen> createState() => _CreateExplainerScreenState();
}

class _CreateExplainerScreenState extends State<CreateExplainerScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<dynamic> _getImages(ToolsProvider provider) {
    return widget.tool?.images ?? provider.imagesFileList!;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final title = args[Constants.title] as String;
    final groupID = args[Constants.groupArg] as String;
    final toolProvider = context.watch<ToolsProvider>();
    final images = _getImages(toolProvider);
    final bool isViewOnly = widget.tool != null;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          title,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePreview(context, images, isViewOnly),
                const SizedBox(height: 16),
                PageIndicator(
                  pageController: _pageController,
                  images: images,
                ),
                const SizedBox(height: 24),
                isViewOnly
                    ? _buildToolDescription(widget.tool!)
                    : _buildInputAndGenerateButton(
                        toolProvider, context, groupID),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(
      BuildContext context, List<dynamic> images, bool isViewOnly) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getBoxShadowTheme(context),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: previewImages(
          context: context,
          images: images,
          pageController: _pageController,
          isViewOnly: isViewOnly,
        ),
      ),
    );
  }

  Widget _buildToolDescription(ToolModel tool) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tool.title, style: AppTheme.textStyle18Bold),
            const SizedBox(height: 8),
            Text(tool.description, style: AppTheme.textStyle16w600),
          ],
        ),
      ),
    );
  }

  Widget _buildInputAndGenerateButton(
      ToolsProvider toolProvider, BuildContext context, String groupID) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Enter description (optional)',
            hintText: 'Description',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[200],
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: OpenContainer(
            closedBuilder: (context, action) {
              return GeminiButton(
                label: 'Generate',
                borderRadius: 25.0,
                onTap: () => _generateTool(
                  context,
                  toolProvider,
                  groupID,
                  action,
                ),
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
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 500),
            closedElevation: AppTheme.cardElevation,
            openElevation: 4,
          ),
        ),
      ],
    );
  }

  void _generateTool(BuildContext context, ToolsProvider toolProvider,
      String groupID, VoidCallback action) async {
    //check if images are added
    if (toolProvider.imagesFileList!.isEmpty) {
      showSnackBar(context: context, message: 'Please add images');
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
      groupID: groupID,
      description: description,
      onSuccess: () {
        // pop the loading dialog
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 500)).whenComplete(action);
      },
      onError: (error) {
        // pop the loading dialog
        Navigator.pop(context);
        showSnackBar(
          context: context,
          message: error,
        );
      },
    );
  }
}


// class CreateExplainerScreen extends StatefulWidget {
//   const CreateExplainerScreen({
//     super.key,
//     this.tool,
//   });

//   final ToolModel? tool;

//   @override
//   State<CreateExplainerScreen> createState() => _CreateExplainerScreenState();
// }

// class _CreateExplainerScreenState extends State<CreateExplainerScreen> {
//   // description controller
//   final TextEditingController _descriptionController = TextEditingController();
//   final PageController _pageController = PageController();

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }

//   _getImages(ToolsProvider provider) {
//     if (widget.tool != null) {
//       return widget.tool!.images;
//     }
//     return provider.imagesFileList!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // get the arguments
//     final args = ModalRoute.of(context)!.settings.arguments as Map;
//     final title = args[Constants.title] as String;
//     final groupID = args[Constants.groupArg] as String;
//     final toolProvider = context.watch<ToolsProvider>();
//     final images = _getImages(toolProvider);
//     final bool isViewOnly = widget.tool != null;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: MyAppBar(
//         leading: const BackButton(),
//         title: title,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: screenHeight * 0.60,
//                 width: MediaQuery.of(context).size.width,
//                 child: previewImages(
//                   context: context,
//                   images: images,
//                   pageController: _pageController,
//                   isViewOnly: isViewOnly,
//                 ),
//               ),
//               const SizedBox(
//                 height: 4,
//               ),
//               PageIndicator(
//                 pageController: _pageController,
//                 images: images,
//               ),
//               const SizedBox(
//                 height: 4,
//               ),
//               isViewOnly
//                   ? buildToolDescriptionText(widget.tool!)
//                   : buildInputGenerationBtn(
//                       toolProvider,
//                       context,
//                       groupID,
//                     ),
//               const SizedBox(
//                 height: 10,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   buildInputGenerationBtn(
//     ToolsProvider toolProvider,
//     BuildContext context,
//     String groupID,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           InputField(
//             labelText: 'Enter description [optional]',
//             hintText: 'Description',
//             controller: _descriptionController,
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: OpenContainer(
//               closedBuilder: (context, action) {
//                 return GeminiButton(
//                   label: 'Generate',
//                   borderRadius: 25.0,
//                   onTap: () async {
//                     //check if images are added
//                     if (toolProvider.imagesFileList!.isEmpty) {
//                       showSnackBar(
//                           context: context, message: 'Please add images');
//                       return;
//                     }

//                     // show my alert dialog for loading
//                     MyDialogs.showMyAnimatedDialog(
//                       context: context,
//                       title: 'Generating',
//                       content: 'Please wait...',
//                       loadingIndicator: const SizedBox(
//                         height: 100,
//                         width: 100,
//                         child: LoadingPPEIcons(),
//                       ),
//                     );

//                     final authProvider = context.read<AuthenticationProvider>();
//                     final description = _descriptionController.text;

//                     await toolProvider.submitPrompt(
//                       creatorID: authProvider.userModel!.uid,
//                       groupID: groupID,
//                       description: description,
//                       onSuccess: () {
//                         // pop the loading dialog
//                         Navigator.pop(context);
//                         Future.delayed(const Duration(milliseconds: 500))
//                             .whenComplete(action);
//                       },
//                       onError: (error) {
//                         // pop the loading dialog
//                         Navigator.pop(context);
//                         showSnackBar(
//                           context: context,
//                           message: error,
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//               openBuilder: (context, action) {
//                 // navigate to details screen
//                 return ExplainerDetailsScreen(
//                   onSave: (value) {
//                     if (value) {
//                       // clear data
//                       toolProvider.clearImages();
//                       _descriptionController.clear();

//                       showSnackBar(
//                           context: context, message: 'Tool Successfully saved');
//                     } else {
//                       showSnackBar(
//                           context: context, message: 'Error saving tool');
//                     }
//                   },
//                 );
//               },
//               closedShape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25)),
//               transitionType: ContainerTransitionType.fadeThrough,
//               transitionDuration: const Duration(milliseconds: 500),
//               closedElevation: AppTheme.cardElevation,
//               openElevation: 4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   buildToolDescriptionText(ToolModel tool) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             tool.title,
//             style: AppTheme.textStyle18w500,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             tool.description,
//             style: AppTheme.textStyle18w500,
//           ),
//         ],
//       ),
//     );
//   }
// }
