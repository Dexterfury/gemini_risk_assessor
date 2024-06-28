import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:image_cropper/image_cropper.dart';

class OrganisationProvider extends ChangeNotifier {
  bool _isLoading = false;
  File? _finalFileImage;
  OrganisationModel? _organisationModel;

  // getters
  bool get isLoading => _isLoading;
  File? get finalFileImage => _finalFileImage;
  OrganisationModel? get organisationModel => _organisationModel;

  // setters
  void setfinalFileImage(File? file) {
    _finalFileImage = file;
    notifyListeners();
  }

  // set loading
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void showImagePickerDialog({
    required BuildContext context,
  }) {
    imagePickerAnimatedDialog(
      context: context,
      title: 'Select Photo',
      content: 'Choose an Option',
      onPressed: (value) {
        if (value) {
          selectImage(
            fromCamera: value,
            onError: (String error) {
              showSnackBar(context: context, message: error);
            },
          );
        } else {
          selectImage(
            fromCamera: value,
            onError: (String error) {
              showSnackBar(context: context, message: error);
            },
          );
        }
      },
    );
  }

  void selectImage({
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    _finalFileImage = await pickUserImage(
      fromCamera: fromCamera,
      onFail: (String message) => onError(message),
    );

    if (_finalFileImage == null) {
      return;
    }

    // crop image
    await cropImage(
      filePath: finalFileImage!.path,
    );
  }

  Future<void> cropImage({
    required String filePath,
  }) async {
    setfinalFileImage(File(filePath));
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
      compressQuality: 90,
    );

    if (croppedFile != null) {
      setfinalFileImage(File(croppedFile.path));
    }
  }
}
