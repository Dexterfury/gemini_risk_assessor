import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:image_picker/image_picker.dart';

String cleanJson(String maybeInvalidJson) {
  if (maybeInvalidJson.contains('```')) {
    final withoutLeading = maybeInvalidJson.split('```json').last;
    final withoutTrailing = withoutLeading.split('```').first;
    return withoutTrailing;
  }
  return maybeInvalidJson;
}

Future<List<XFile>?> pickImages({
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
final List<PpeModel> ppeIcons = [
  PpeModel(
    id: 1,
    label: 'Dust Mask',
    icon: CircleAvatar(
      radius: 20,
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
      radius: 20,
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
      radius: 20,
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
      radius: 20,
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
      radius: 20,
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
      radius: 20,
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
      radius: 20,
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
      radius: 20,
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
      radius: 20,
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
      radius: 20,
      backgroundColor: Colors.blue,
      backgroundImage: AssetImage(
        AssetsManager.safetyHarness,
      ),
    ),
  ),
  PpeModel(
    id: 12,
    label: 'Other',
    icon: const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.blue,
      child: Text(''),
    ),
  ),
];
