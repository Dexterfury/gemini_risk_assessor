import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AssessmentProvider extends ChangeNotifier {
  List<PpeModel> _ppeModelList = [];
  List<XFile>? _imagesFileList = [];
  bool _fromCamera = false;
  int _maxImages = 10;
  int _numberOfPeople = 1;
  String _description = '';

  // getters
  List<PpeModel> get ppeModelList => _ppeModelList;
  List<XFile>? get imagesFileList => _imagesFileList;
  bool get fromCamera => _fromCamera;
  int get maxImages => _maxImages;
  int get numberOfPeople => _numberOfPeople;
  String get description => _description;

  // setters

  // set from camera
  Future<void> setFromCamera(bool value) async {
    _fromCamera = value;
    notifyListeners();
  }

  // set max images
  void setMaxImages(int value) {
    _maxImages = value;
    notifyListeners();
  }

  // increment number of people
  void incrementNumberOfPeople() {
    _numberOfPeople++;
    notifyListeners();
  }

  // decreament number of people
  void decrementNumberOfPeople() {
    _numberOfPeople--;
    notifyListeners();
  }

  // set number of people
  void setNumberOfPeople({required int value}) {
    _numberOfPeople = value;
    notifyListeners();
  }

  // set description
  void setDescription({required String value}) {
    _description = value;
    notifyListeners();
  }

  // add ppe model item
  void addOrRemovePpeModelItem({required PpeModel ppeItem}) {
    // check ppeModelList contains ppeItem
    if (_ppeModelList.contains(ppeItem)) {
      // remove ppeItem
      _ppeModelList.remove(ppeItem);
    } else {
      _ppeModelList.add(ppeItem);
    }
    notifyListeners();
  }

  // remove file
  void removeFile({required XFile image}) {
    _imagesFileList!.removeWhere((file) => file == image);
    // update maximum number of images
    _maxImages = _maxImages + 1;
    notifyListeners();
  }

  Future<void> selectImages({
    required Function() onSuccess,
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
    // check if files were selected
    if (returnedFiles != null) {
      // check if taken from camera
      if (_fromCamera) {
        // this is only one image so crop it
        await cropImage(
          path: returnedFiles.first.path,
          onSuccess: onSuccess,
        );
      } else {
        // add each image into imagesFileList
        for (var file in returnedFiles) {
          _imagesFileList!.add(file);
          notifyListeners();
        }
        // update maximum number of images
        _maxImages = _maxImages - returnedFiles.length;
        notifyListeners();
        onSuccess();
      }
    }
  }

  // crop image
  Future<void> cropImage({
    required String path,
    required Function() onSuccess,
  }) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
    );

    if (croppedFile != null) {
      // add the cropped image into imagesFileList as XFile
      _imagesFileList!.add(XFile(croppedFile.path));
      // update maximum number of images
      _maxImages = _maxImages - 1;
      notifyListeners();
      onSuccess();
    }
  }

  void showBottomSheet({
    required BuildContext context,
    required Function(String) onError,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                await setFromCamera(true);
                await selectImages(
                  onSuccess: () {
                    // pop the bottom sheet
                    Navigator.pop(context);
                  },
                  onError: (error) => onError(error),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () async {
                await setFromCamera(false);
                await selectImages(
                  onSuccess: () {
                    // pop the bottom sheet
                    Navigator.pop(context);
                  },
                  onError: (error) => onError(error),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // get api key from env
  getApiKey() {
    return dotenv.env['APIKEY'];
  }
}
