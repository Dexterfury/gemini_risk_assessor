import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:gemini_risk_assessor/firebase_methods/error_handler.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/prompt_data_model.dart';
import 'package:path/path.dart' as path;

class ToolsProvider extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  bool _isLoading = false;
  int _maxImages = 10;
  String _description = '';
  File? _pdfToolFile;
  String _uid = '';
  String _groupID = '';
  List<XFile>? _imagesFileList = [];
  ToolModel? _toolModel;
  List<ToolModel> _toolsList = [];

  // getters
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  String get description => _description;
  File? get pdfToolFile => _pdfToolFile;
  String get uid => _uid;
  String get groupID => _groupID;
  List<XFile>? get imagesFileList => _imagesFileList;
  ToolModel? get toolModel => _toolModel;
  List<ToolModel> get toolsList => _toolsList;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);

  Future<bool> saveToolToFirestore() async {
    if (_toolModel != null) {
      try {
        String id = _groupID.isNotEmpty ? _groupID : _uid;

        if (_toolModel!.images.isNotEmpty) {
          List<String> imagesUrls = [];
          for (var image in _toolModel!.images) {
            final imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
              file: File(image),
              reference:
                  '${Constants.images}/tools/$id/${DateTime.now().toIso8601String()}${path.extension(image)}',
            );
            imagesUrls.add(imageUrl);
          }

          _toolModel!.images = imagesUrls;
        }

        await _usersCollection
            .doc(id)
            .collection(Constants.toolsCollection)
            .doc(_toolModel!.id)
            .set(
              _toolModel!.toJson(),
            );

        return true; // Indicate successful save
      } catch (e, stack) {
        ErrorHandler.recordError(e, stack, reason: 'Error saving tool: $e');
        return false;
      }
    }
    return false; // No tool model to save
  }

  // Add a method to clear the entered data
  void clearImages() {
    _imagesFileList = [];
    notifyListeners();
  }

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

  Future<void> setToolData(
    String desc,
    String creatorID,
    String groupID,
  ) async {
    _description = desc;
    _uid = creatorID;
    _groupID = groupID;
    notifyListeners();
  }

  Future<void> selectImages({
    required BuildContext context,
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    final returnedFiles = await ImagePickerHandler.pickPromptImages(
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
        // Show loading dialog before cropping image
        ImagePickerHandler.showLoadingDialog(context, 'Preparing to crop...');
        // this is only one image so crop it
        await cropImage(
          context: context,
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
    required BuildContext context,
    required String path,
  }) async {
    // Dismiss the preparing to crop loading dialog
    Navigator.of(context).pop();

    // show loading dialog before cropping image
    ImagePickerHandler.showLoadingDialog(context, 'Cropping image...');
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
    );

    Navigator.of(context).pop(); // Dismiss cropping loading dialog

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
    ImagePickerHandler.imagePickerAnimatedDialog(
      context: context,
      title: 'Select Photo',
      content: 'Choose an Option',
      onPressed: (value) {
        selectImages(
          context: context,
          fromCamera: value,
          onError: (String error) {
            if (context.mounted) {
              //showSnackBar(context: context, message: error);
            }
          },
        );
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
    required String groupID,
    required String description,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      var model = await _modelManager.getModel(
        isVision: _maxImages < 10,
        isDocumentSpecific: true,
      );

      await setToolData(
        description,
        creatorID,
        groupID,
      );

      final prompt = getPromptData();

      final content = await _modelManager.generateContent(model, prompt);

      if (content.text != null && content.text!.contains(noToolFound)) {
        _isLoading = false;
        onError(noToolFound);
        return;
      }

      final List<String> images = [];
      if (_imagesFileList != null) {
        for (var image in _imagesFileList!) {
          images.add(image.path);
        }
      }

      final toolId = const Uuid().v4();
      _toolModel = ToolModel.fromGeneratedContent(
        content,
        toolId,
        creatorID,
        groupID,
        images,
        DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      if (error is SocketException) {
        onError(
            "Network error: Unable to connect to the server. Please check your internet connection and try again.");
      } else if (error is TimeoutException) {
        onError("Request timed out. Please try again later.");
      } else if (error is HttpException) {
        onError("HTTP error occurred: ${error.message}");
      } else {
        onError("An unexpected error occurred: ${error.toString()}");
      }

      if (kDebugMode) {
        print('error### : $error');
      }
    }
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

  static String noToolFound =
      "No tools identified based on information provided";

  final String format = '''
Return the response as valid JSON using the following structure:
{
  "title": \$title,
  "description": \$description,
  "summary": \$summary,
}
  
name, description and summary should be of type String.
''';
}
