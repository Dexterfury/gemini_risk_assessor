import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/models/prompt_data_model.dart';
import 'package:gemini_risk_assessor/service/gemini.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AssessmentProvider extends ChangeNotifier {
  List<PpeModel> _ppeModelList = [];
  List<XFile>? _imagesFileList = [];
  bool _fromCamera = false;
  bool _isLoading = false;
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

  // function to set the model based on bool - isTextOnly
  Future<GenerativeModel> getModel() async {
    if (_maxImages < 10) {
      return GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: const String.fromEnvironment('API_KEY'),
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        ],
      );
    } else {
      return GenerativeModel(
        model: 'gemini-pro',
        apiKey: const String.fromEnvironment('API_KEY'),
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        ],
      );
    }
  }

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

  // get labels from ppeModelList
  List<String> getPpeLabels() {
    return _ppeModelList.map((ppe) => ppe.label).toList();
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
  String getApiKey() {
    return dotenv.env['API_KEY'].toString();
  }

  String getSelectedPpe() {
    return _ppeModelList.map((ppe) => ppe.label).join(', ');
  }

  PromptDataModel getPromptData() {
    return PromptDataModel(
      images: _imagesFileList!,
      textInput: mainPrompt,
      numberOfPeople: _numberOfPeople.toString(),
      selectedPpe: getSelectedPpe.toString(),
      additionalTextInputs: [format],
    );
  }

  // reset prompt data
  void resetPromptData() {
    _imagesFileList = [];
    _maxImages = 10;
    _numberOfPeople = 1;
    _ppeModelList = [];
  }

  Future<void> submitPrompt() async {
    _isLoading = true;
    notifyListeners();
    // get model to use text or vision
    var model = await getModel();
    final prompt = getPromptData();

    try {
      final content = await GeminiService.generateContent(model, prompt);

      // handle no image or image of not-food
      if (content.text != null && content.text!.contains(noRiskFound)) {
        // show error message
        log('content error: $content');
      } else {
        log('content: $content');
      }
    } catch (error) {
      // geminiFailureResponse = 'Failed to reach Gemini. \n\n$error';
      log('just error: $error');
      if (kDebugMode) {
        print(error);
      }
      _isLoading = false;
    }

    _isLoading = false;
    resetPromptData();
    notifyListeners();
  }

  String get mainPrompt {
    return '''
You are a Safety officer who ensures safe work practices.

Generate a risk assessment based on the data information provided below.
The assessment should only contain real practical risks identified and mitigation measures proposed without any unnecessary information.
If there are no images attached, or if the image does not contain any identifiable risks, respond exactly with: $noRiskFound.

Adhere to Safety standards and regulations. Identify any potential risks and propose practical mitigation measures.
The number of people is: $_numberOfPeople

After providing the assessment, advice the equipment and tools to be used if required.
Advise about the dangers that could injure people or harm the enviroment, the hazards and risks involved.
Propose practical measures to eliminate or minimize each risk identified.
Suggest use of proper personal protective equipment if not among these: ${getSelectedPpe.toString()}
Provide a summary of this assessment.

${_description.isNotEmpty ? _description : ''}
''';
  }

  String noRiskFound =
      "No risks identified based on information and images provided";

  final String format = '''
Return the recipe as valid JSON using the following structure:
{
  "id": \$uniqueId,
  "title": \$assessmentTitle,
  "taskToAchieve": \$taskToAchieve,
  "equipments": \$equipments,
  "hazards": \$hazards,
  "risks": \$risks,
  "control": \$control,
  "summary": \$summary,
}
  
uniqueId should be unique and of type String.
equipments, hazards and risks should be of type List<String>.
''';
}
