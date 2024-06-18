import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/widgets/image_picker_item.dart';
import 'package:image_picker/image_picker.dart';

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

// list of ppe icons
List<PpeModel> ppeIcons({
  double radius = 20,
}) {
  return [
    PpeModel(
      id: 1,
      label: 'Dust Mask',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.dustMask,
        ),
      ),
    ),
    PpeModel(
      id: 2,
      label: 'Ear Protection',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.earProtection,
        ),
      ),
    ),
    PpeModel(
      id: 3,
      label: 'Face Shield',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.faceShield,
        ),
      ),
    ),
    PpeModel(
      id: 4,
      label: 'Foot Protection',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.footProtection,
        ),
      ),
    ),
    PpeModel(
      id: 5,
      label: 'Hand Protection',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.handProtection,
        ),
      ),
    ),
    PpeModel(
      id: 6,
      label: 'Head Protection',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.headProtection,
        ),
      ),
    ),
    PpeModel(
      id: 7,
      label: 'High Vis Clothing',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.highVisClothing,
        ),
      ),
    ),
    PpeModel(
      id: 8,
      label: 'Life Jacket',
      icon: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.lifeJacket,
        ),
      ),
    ),
    PpeModel(
      id: 9,
      label: 'Protective Clothing',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.protectiveClothing,
        ),
      ),
    ),
    PpeModel(
      id: 10,
      label: 'Safety Glasses',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.safetyGlasses,
        ),
      ),
    ),
    PpeModel(
      id: 11,
      label: 'Safety Harness',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage(
          AssetsManager.safetyHarness,
        ),
      ),
    ),
    PpeModel(
      id: 12,
      label: 'Other',
      icon: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue,
        child: const Text(''),
      ),
    ),
  ];
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
void imagePickerAnimatedDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Function(bool) onPressed,
}) {
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImagePickerItem(
                        label: 'Camera',
                        iconData: Icons.camera_alt,
                        onPressed: () {
                          Navigator.pop(context);
                          onPressed(true);
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ImagePickerItem(
                        label: 'Gallery',
                        iconData: Icons.image,
                        onPressed: () {
                          Navigator.pop(context);
                          onPressed(false);
                        },
                      ),
                    ],
                  )
                ],
              ),
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

// store file to storage and return file url
Future<String> storeFileToStorage({
  required File file,
  required String reference,
}) async {
  UploadTask uploadTask =
      FirebaseStorage.instance.ref().child(reference).putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask;
  String fileUrl = await taskSnapshot.ref.getDownloadURL();
  return fileUrl;
}
