import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/constants.dart';
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
  List<ToolModel> _toolsList = [];

  // getters
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  String get description => _description;
  File? get pdfToolFile => _pdfToolFile;
  String get uid => _uid;
  List<XFile>? get imagesFileList => _imagesFileList;
  ToolModel? get toolModel => _toolModel;
  List<ToolModel> get toolsList => _toolsList;

  final CollectionReference toolsCollection =
      FirebaseFirestore.instance.collection(Constants.toolsCollection);

  // save tool to firestore
  Future<void> saveToolToFirestore() async {
    if (_toolModel != null) {
      await toolsCollection.add(_toolModel!.toJson());
    }
  }

  setTestToolsList() {
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

  // get tools list from firestore
  Future<void> getToolsListFromFirestore() async {
    final querySnapshot =
        await toolsCollection.where(Constants.createdBy, isEqualTo: _uid).get();
    _toolsList = [];
    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        _toolsList.add(ToolModel.fromJson(doc.data() as Map<String, dynamic>));
      }
    }

    notifyListeners();
  }

  // stream my tools from firestore
  Stream<QuerySnapshot> streamMyTools() {
    return toolsCollection
        .where(Constants.createdBy, isEqualTo: _uid)
        .snapshots();
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

  Future<void> testPrompt() async {
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
