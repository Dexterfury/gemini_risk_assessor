import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/prompt_data_model.dart';
import '../service/gemini.dart';
import '../utilities/global.dart';

class ToolProvider extends ChangeNotifier {
  bool _isLoading = false;
  int _maxImages = 10;
  String _description = '';
  File? _pdfToolFile;
  String _uid = '';
  List<XFile>? _imagesFileList = [];
  ToolModel? _toolModel;

  // getters
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  String get description => _description;
  File? get pdfToolFile => _pdfToolFile;
  String get uid => _uid;
  List<XFile>? get imagesFileList => _imagesFileList;
  ToolModel? get toolModel => _toolModel;

  // set max images
  void setMaxImages(int value) {
    _maxImages = value;
    notifyListeners();
  }

  // remove file
  void removeFile({required XFile image}) {
    _imagesFileList!.removeWhere((file) => file == image);
    // update maximum number of images
    _maxImages = _maxImages + 1;
    notifyListeners();
  }

  Future<void> setDescription(String desc, String creatorID) async {
    _description = desc;
    _uid = creatorID;
    notifyListeners();
  }

  Future<void> selectImages({
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    final returnedFiles = await pickPromptImages(
      fromCamera: fromCamera,
      maxImages: _maxImages,
      onError: (error) {
        // return error to onError
        onError(error.toString());
      },
    );
    // check if files were selected
    if (returnedFiles != null) {
      // check if taken from camera
      if (fromCamera) {
        // this is only one image so crop it
        await cropImage(
          path: returnedFiles.first.path,
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
      }
    }
  }

  // crop image
  Future<void> cropImage({
    required String path,
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
    }
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
          selectImages(
            fromCamera: value,
            onError: (String error) {
              if (context.mounted) {
                showSnackBar(context: context, message: error);
              }
            },
          );
        } else {
          selectImages(
            fromCamera: value,
            onError: (String error) {
              if (context.mounted) {
                showSnackBar(context: context, message: error);
              }
            },
          );
        }
      },
    );
  }

  PromptDataModel getPromptData() {
    return PromptDataModel(
      images: _imagesFileList!,
      textInput: mainPrompt,
      numberOfPeople: '1',
      selectedPpe: '',
      additionalTextInputs: [format],
    );
  }

  // reset prompt data
  void resetPromptData() {
    _imagesFileList = [];
    _maxImages = 10;
    notifyListeners();
  }

  Future<void> submitPrompt({
    required String creatorID,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();
    // get model to use text or vision
    var model = await GeminiService.getModel(images: _maxImages);

    // set description to use in prompt
    await setDescription(description, creatorID);

    // get promptDara
    final prompt = getPromptData();

    try {
      final content = await GeminiService.generateContent(model, prompt);

      // handle no image or image of not-food
      if (content.text != null && content.text!.contains(noToolFound)) {
        // show error message
        _isLoading = false;
      } else {
        final List<String> images = [];
        if (_imagesFileList != null) {
          for (var image in _imagesFileList!) {
            images.add(image.path);
          }
        }
        _toolModel = ToolModel.fromGeneratedContent(
          content,
          creatorID,
          images,
          DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      _isLoading = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  String get mainPrompt {
    return '''
You are a tools expert.

Generate a full description of a tool or tools based on the data information provided below.
Explain how to use this tool and give practical use case example.
If there are no images attached, or if the image does not contain any identifiable tool, respond exactly with: $noToolFound.

Adhere to Safety standards and regulations, give safe and effective use of tools.

After providing the description, suggest other similar tools as optional if there are any.

${_description.isNotEmpty ? _description : ''}
''';
  }

  String noToolFound =
      "No tools identified based on information and images provided";

  final String format = '''
Return the response as valid JSON using the following structure:
{
  "id": \$uniqueId,
  "name": \$name,
  "description": \$description,
  "summary": \$summary,
}
  
uniqueId should be unique and of type String.
name, description and summary should be of type String.
''';
}
