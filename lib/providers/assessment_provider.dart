import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:image_picker/image_picker.dart';

class AssessmentProvider extends ChangeNotifier {
  List<XFile>? _imagesFileList;
  bool _fromCamera = false;
  int _maxImages = 10;

  // getters
  List<XFile>? get imagesFileList => _imagesFileList;
  bool get fromCamera => _fromCamera;
  int get maxImages => _maxImages;

  // setters

  // set from camera
  void setFromCamera(bool value) {
    _fromCamera = value;
    notifyListeners();
  }

  // set max images
  void setMaxImages(int value) {
    _maxImages = value;
    notifyListeners();
  }

  // remove file

  Future<void> selectImages({
    required Function(String) onError,
  }) async {
    final returnedFiles = await pickImages(
      fromCamera: _fromCamera,
      maxImages: _maxImages,
      onError: (error) {
        // return error to onError
        onError(error.toString());
      },
    );
    if (returnedFiles != null) {
      // add each image into imagesFileList
      for (var file in returnedFiles) {
        _imagesFileList!.add(file);
        notifyListeners();
      }
      // update maximum number of images
      _maxImages = _maxImages - returnedFiles.length;
      notifyListeners();
    }
  }
}
