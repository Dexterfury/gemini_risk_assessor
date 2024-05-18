import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage({required bool fromCamera}) async {
  File? fileImage;
  if (fromCamera) {
    // pick image from camera
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      fileImage = File(pickedImage.path);
    }
  } else {
    // pick image from gallery
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      fileImage = File(pickedImage.path);
    }
  }

  return fileImage;
}
