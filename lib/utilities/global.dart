import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/widgets/image_picker_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/tool_provider.dart';
import '../themes/my_themes.dart';
import '../widgets/main_app_button.dart';

String cleanJson(String maybeInvalidJson) {
  if (maybeInvalidJson.contains('```')) {
    final withoutLeading = maybeInvalidJson.split('```json').last;
    final withoutTrailing = withoutLeading.split('```').first;
    return withoutTrailing;
  }
  return maybeInvalidJson;
}

// picp image from gallery or camera
Future<File?> pickUserImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if (fromCamera) {
    // get picture from camera
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        onFail('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  } else {
    // get picture from gallery
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  }

  return fileImage;
}

Future<List<XFile>?> pickPromptImages({
  required bool fromCamera,
  required int maxImages,
  required Function(String) onError,
}) async {
  try {
    // pick image from camera
    if (fromCamera) {
      List<XFile> fileImages = [];
      final takeImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (takeImage != null) {
        fileImages.add(takeImage);
        return fileImages;
      } else {
        return onError('No image taken');
      }
    } else {
      final pickedImages = await ImagePicker().pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
        limit: maxImages,
      );
      if (pickedImages.isNotEmpty) {
        return pickedImages;
      } else {
        onError('No images selected');
        return [];
      }
    }
  } catch (e) {
    onError(e.toString());
    return [];
  }
}

// show snackbar
showSnackBar({
  required BuildContext context,
  required String message,
}) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// get label
getLabel(ListHeader label) {
  switch (label) {
    case ListHeader.equipments:
      return 'Equipments:';
    case ListHeader.hazards:
      return 'Hazards:';
    case ListHeader.risks:
      return 'Risks:';
    case ListHeader.control:
      return 'Control Measures:';
    case ListHeader.ppe:
      return 'Personal Project Equipment (PPE):';
    case ListHeader.signatures:
      return 'Signatures:';
    default:
      return 'Unknown';
  }
}

IconData getWeatherIcon(Weather weather) {
  return weather == Weather.sunny
      ? Icons.wb_sunny_outlined
      : weather == Weather.rain
          ? Icons.shower
          : weather == Weather.windy
              ? Icons.wind_power
              : Icons.snowing;
}

// animated dialog
void showMyAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  Widget? loadingIndicator, // loading indicator
  Widget? signatureInput, // signature field
  List<Widget>? actions,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  loadingIndicator ?? const SizedBox(),
                  signatureInput ?? const SizedBox(),
                ],
              ),
              actions: actions,
            ),
          ));
    },
  );
}

// animated dialog
void showMyEditAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  String hintText = '',
  required String textAction,
  required Function(bool, String) onActionTap,
}) {
  TextEditingController controller = TextEditingController(text: hintText);
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: AlertDialog(
              title: Text(
                title,
                textAlign: TextAlign.center,
              ),
              content: TextField(
                controller: controller,
                maxLength: content == Constants.changeName ? 20 : 500,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: hintText,
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(
                      false,
                      controller.text,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onActionTap(
                      true,
                      controller.text,
                    );
                  },
                  child: Text(textAction),
                ),
              ],
            ),
          ));
    },
  );
}

// general bacl icon
Widget backIcon(BuildContext context) {
  return IconButton(
    onPressed: () => Navigator.pop(context),
    icon: Icon(
      Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
    ),
  );
}

Widget previewImages({
  required BuildContext context,
  required List<dynamic> images,
  required PageController pageController,
  required bool isViewOnly,
}) {
  final toolsProvider = context.read<ToolsProvider>();
  if (images.isNotEmpty) {
    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: images.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final image = images[index];
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.60,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: isViewOnly
                            ?
                            // Image.network(
                            //     image,
                            //     fit: BoxFit.cover,
                            //   )
                            Image.file(
                                File(image),
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(image.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: () {
                            // remove image from list
                            toolsProvider.removeFile(image: image);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // add images button
        Positioned(
          left: 20,
          bottom: 20,
          child: MainAppButton(
            icon: Icons.camera_alt_rounded,
            label: '+',
            onTap: () {
              toolsProvider.showImagePickerDialog(
                context: context,
              );
            },
          ),
        )
      ],
    );
  } else {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.60,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey.shade200,
          child: Center(
            child: GestureDetector(
              onTap: () {
                toolsProvider.showImagePickerDialog(
                  context: context,
                );
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Click here to add images",
                    textAlign: TextAlign.center,
                    style: textStyle18w500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
