import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/image_picker_item.dart';
import 'package:image_cropper/image_cropper.dart';

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
            fromCamera: value,
            onError: (String error) {
              showSnackBar(context: context, message: error);
            },
          );
          completer.complete(result);
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
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    final filePicked = await pickUserImage(
        fromCamera: fromCamera,
        onFail: (String message) {
          onError(message);
        });

    if (filePicked == null) {
      return null;
    }

    // crop image
    final croppedFile = await cropImage(
      filePath: filePicked.path,
    );

    return croppedFile;
  }

  static Future<File?> cropImage({
    required String filePath,
  }) async {
    //setfinalFileImage(File(filePath));
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
      compressQuality: 90,
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
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
