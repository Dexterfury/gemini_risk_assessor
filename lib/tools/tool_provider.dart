import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/prompt_data_model.dart';
import '../utilities/global.dart';
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
      } catch (e) {
        print("Error saving tool: $e");
        return false; // Indicate failed save
      }
    }
    return false; // No tool model to save
  }

  // Add a method to clear the entered data
  void clearImages() {
    _imagesFileList = [];
    notifyListeners();
  }

  setMacTestToolsList() {
    final Map<String, dynamic> dataMap = {
      Constants.id: '774b4250-0628-4381-a921-636009b3941c',
      Constants.name: 'Brick Trowel Set',
      Constants.description:
          'This set of three brick trowels is perfect for any masonry project. The largest trowel is ideal for spreading mortar and leveling bricks, while the smaller trowels are perfect for finishing work and applying grout. The trowels are made of high-quality stainless steel with comfortable, ergonomic handles. To use the trowels, simply dip the blade into the mortar and spread it evenly onto the surface. Then, use the trowel to level the mortar and place the bricks. Once the bricks are in place, use the trowel to apply grout to the joints. When using the trowels, be sure to wear safety glasses and gloves to protect yourself from debris and mortar. Always use a firm grip on the handle and avoid using excessive force.',
      Constants.summary:
          'This set of three brick trowels is perfect for any masonry project. The trowels are made of high-quality stainless steel with comfortable, ergonomic handles.',
      Constants.toolPdf: '',
      Constants.images: [
        '/data/user/0/com.raphaeldaka.geminiriskassessor/cache/scaled_1000000019.jpg'
      ],
      Constants.createdBy: 'bl5Beci5pcfsuvwtU11XgFUv29X2',
      Constants.createdAt: 1718868958685,
    };

    _toolModel = ToolModel.fromJson(dataMap);

    _toolsList = [];

    // make alist of 10 tools
    for (int i = 0; i < 10; i++) {
      _toolsList.add(_toolModel!);
    }
    log('testTools');
    notifyListeners();
  }

  setWindowsTestToolsList() {
    final Map<String, dynamic> dataMap = {
      Constants.id: 'd9320635-5a71-4437-a526-172957038b92',
      Constants.name: 'Claw Hammer',
      Constants.description:
          'A claw hammer is a versatile tool used for driving nails and removing them. It consists of a wooden or fiberglass handle attached to a metal head with a hammer face on one side and a claw on the other. To drive a nail, hold the hammer near the end of the handle for more force or closer to the head for more control. Swing the hammer in a smooth arc, striking the nail head squarely. To remove a nail, place the claw under the nail head and rock the hammer back and forth until the nail is loose. Be careful not to damage the surrounding material when removing nails. ',
      Constants.summary:
          'A claw hammer is a common tool used for driving and removing nails in various applications, from construction and carpentry to home repairs.',
      Constants.toolPdf: '',
      Constants.images: [
        '/data/user/0/com.raphaeldaka.geminiriskassessor/cache/scaled_1000000033.jpg'
      ],
      Constants.createdBy: 'bl5Beci5pcfsuvwtU11XgFUv29X2',
      Constants.createdAt: 1718868958685,
    };

    _toolModel = ToolModel.fromJson(dataMap);

    _toolsList = [];

    // make alist of 10 tools
    for (int i = 0; i < 10; i++) {
      _toolsList.add(_toolModel!);
    }
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

  Future<void> macTestPrompt() async {
    final Map<String, dynamic> dataMap = {
      Constants.id: '774b4250-0628-4381-a921-636009b3941c',
      Constants.name: 'Brick Trowel Set',
      Constants.description:
          'This set of three brick trowels is perfect for any masonry project. The largest trowel is ideal for spreading mortar and leveling bricks, while the smaller trowels are perfect for finishing work and applying grout. The trowels are made of high-quality stainless steel with comfortable, ergonomic handles. To use the trowels, simply dip the blade into the mortar and spread it evenly onto the surface. Then, use the trowel to level the mortar and place the bricks. Once the bricks are in place, use the trowel to apply grout to the joints. When using the trowels, be sure to wear safety glasses and gloves to protect yourself from debris and mortar. Always use a firm grip on the handle and avoid using excessive force.',
      Constants.summary:
          'This set of three brick trowels is perfect for any masonry project. The trowels are made of high-quality stainless steel with comfortable, ergonomic handles.',
      Constants.toolPdf: '',
      Constants.images: [
        '/data/user/0/com.raphaeldaka.geminiriskassessor/cache/scaled_1000000019.jpg'
      ],
      Constants.createdBy: 'bl5Beci5pcfsuvwtU11XgFUv29X2',
      Constants.createdAt: 1718868958685,
    };

    _toolModel = ToolModel.fromJson(dataMap);
    notifyListeners();
  }

  Future<void> windowstestPrompt() async {
    final Map<String, dynamic> dataMap = {
      Constants.id: 'd9320635-5a71-4437-a526-172957038b92',
      Constants.name: 'Claw Hammer',
      Constants.description:
          'A claw hammer is a versatile tool used for driving nails and removing them. It consists of a wooden or fiberglass handle attached to a metal head with a hammer face on one side and a claw on the other. To drive a nail, hold the hammer near the end of the handle for more force or closer to the head for more control. Swing the hammer in a smooth arc, striking the nail head squarely. To remove a nail, place the claw under the nail head and rock the hammer back and forth until the nail is loose. Be careful not to damage the surrounding material when removing nails. ',
      Constants.summary:
          'A claw hammer is a common tool used for driving and removing nails in various applications, from construction and carpentry to home repairs.',
      Constants.toolPdf: '',
      Constants.images: [
        '/data/user/0/com.raphaeldaka.geminiriskassessor/cache/scaled_1000000033.jpg'
      ],
      Constants.createdBy: 'bl5Beci5pcfsuvwtU11XgFUv29X2',
      Constants.createdAt: 1718868958685,
    };

    _toolModel = ToolModel.fromJson(dataMap);
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
