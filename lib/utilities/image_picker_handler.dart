import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/image_picker_item.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHandler {
  static Future<File?> showImagePickerDialog({
    required BuildContext context,
  }) async {
    Completer<File?> completer = Completer<File?>();

    await imagePickerAnimatedDialog(
      context: context,
      title: 'Select Photo',
      content: 'Choose an Option',
      onPressed: (value) async {
        try {
          File? result = await selectImage(
            context: context,
            fromCamera: value,
            onError: (String error) {
              showSnackBar(context: context, message: error);
            },
          );

          if (result != null) {
            // Show loading dialog before cropping
            showLoadingDialog(context, 'Preparing to crop...');

            File? croppedFile = await cropImage(
              context: context,
              filePath: result.path,
            );

            completer.complete(croppedFile);
          } else {
            completer.complete(null);
          }
        } catch (e) {
          completer.completeError(e);
          log('message: $e');
        }
      },
    );

    File? result = await completer.future;
    return result;
  }

  static Future<File?> selectImage({
    required BuildContext context,
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    final filePicked = await pickUserImage(
        fromCamera: fromCamera,
        onFail: (String message) {
          onError(message);
        });

    return filePicked;
  }

  static Future<File?> cropImage({
    required BuildContext context,
    required String filePath,
  }) async {
    Navigator.of(context).pop(); // Dismiss previous loading dialog
    showLoadingDialog(context, 'Cropping image...');

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
      compressQuality: 90,
    );

    Navigator.of(context).pop(); // Dismiss cropping loading dialog

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  static Future<List<XFile>?> pickPromptImages({
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

  // animated dialog
  static Future<void> imagePickerAnimatedDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Function(bool) onPressed,
  }) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ImagePickerItem(
                        label: 'Camera',
                        iconData: Icons.camera_alt,
                        onPressed: () {
                          Navigator.pop(context);
                          onPressed(true);
                        },
                      ),
                      const SizedBox(width: 24),
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
              backgroundColor: Theme.of(context).cardColor,
              elevation: 8,
            ),
          ),
        );
      },
    );
  }
}
