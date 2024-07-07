import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/api/pdf_api.dart';
import 'package:gemini_risk_assessor/api/pdf_handler.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/models/prompt_data_model.dart';
import 'package:gemini_risk_assessor/service/gemini.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class AssessmentProvider extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  List<PpeModel> _ppeModelList = [];
  List<XFile>? _imagesFileList = [];
  bool _isLoading = false;
  int _maxImages = 10;
  int _numberOfPeople = 1;
  String _description = '';
  String _pdfHeading = '';
  AssessmentModel _assessmentModel =
      AssessmentModel.fromJson(<String, dynamic>{});
  Weather _weather = Weather.sunny;
  File? _pdfAssessmentFile;
  bool _hasSigned = false;
  Uint8List? _signatureImage;
  String _organisationID = '';
  String _uid = '';
  final GlobalKey<SfSignaturePadState> _signatureGlobalKey = GlobalKey();

  // getters
  List<PpeModel> get ppeModelList => _ppeModelList;
  List<XFile>? get imagesFileList => _imagesFileList;
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  int get numberOfPeople => _numberOfPeople;
  String get pdfHeading => _pdfHeading;
  String get description => _description;
  AssessmentModel get assessmentModel => _assessmentModel;
  Weather get weather => _weather;
  File? get pdfAssessmentFile => _pdfAssessmentFile;
  bool get hasSigned => _hasSigned;
  Uint8List? get signatureImage => _signatureImage;
  String get organisationID => _organisationID;
  String get uid => _uid;
  GlobalKey<SfSignaturePadState> get signatureGlobalKey => _signatureGlobalKey;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _assessmentCollection =
      FirebaseFirestore.instance.collection(Constants.assessmentCollection);
  final CollectionReference _organisationCollection =
      FirebaseFirestore.instance.collection(Constants.organisationCollection);
  final CollectionReference _dstiCollection =
      FirebaseFirestore.instance.collection(Constants.dstiCollections);

  Future<void> setDocData(
    String desc,
    String creatorID,
    String orgID,
    String docTitle,
  ) async {
    _description = desc;
    _uid = creatorID;
    _organisationID = orgID;
    _pdfHeading = docTitle;
    notifyListeners();
  }

  // set loading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // create pdf assessment file
  Future<void> createPdfAndSave() async {
    // set loading
    _isLoading = true;
    notifyListeners();
    final creatorName = await getCreatorName(_assessmentModel.createdBy);
    final file = await PdfApi.generatePdf(
      assessmentModel: _assessmentModel,
      signatureImage: _signatureImage!,
      heading: _pdfHeading,
      creatorName: creatorName,
    );

    _pdfAssessmentFile = file;
    print("PDF file path: ${file.absolute.path}");
    print("PDF file exists: ${file.existsSync()}");

    if (file.existsSync()) {
      await OpenFile.open((file.path));
      await saveFileToFirestore(file.absolute, _pdfHeading);
    } else {
      throw FileSystemException("PDF file does not exist", file.path);
    }
  }

  Future<String> getCreatorName(String creatorId) async {
    final userDoc = await _firestore
        .collection(Constants.usersCollection)
        .doc(creatorId)
        .get();
    return userDoc[Constants.name];
  }

  // save assement to firetore
  Future<void> saveFileToFirestore(
    File file,
    String pdfHeading,
  ) async {
    final id = _organisationID.isNotEmpty ? _organisationID : _uid;
    // get folder directory
    final folderName = Constants.getFolderName(pdfHeading);

    String fileUrl = await FileUploadHandler.uploadFileAndGetUrl(
      file: file,
      reference:
          '${Constants.pdfFiles}/$folderName/$id/${assessmentModel.id}.pdf',
    );

    if (_assessmentModel.images.isNotEmpty) {
      List<String> imagesUrls = [];
      for (var image in _assessmentModel.images) {
        final imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
          file: File(image),
          reference:
              '${Constants.images}/$folderName/$id/${DateTime.now().toIso8601String()}${path.extension(image)}',
        );
        imagesUrls.add(imageUrl);
      }

      _assessmentModel.images = imagesUrls;
    }

    // set pdf and images
    _assessmentModel.pdfUrl = fileUrl;

    if (_organisationID.isEmpty) {
      if (_pdfHeading == Constants.riskAssessment) {
        // save to user's database
        await _assessmentCollection
            .doc(id)
            .collection(Constants.assessmentCollection)
            .doc(assessmentModel.id)
            .set(assessmentModel.toJson());
        // save to user's database end.
      } else {
        // save to user's database
        await _dstiCollection
            .doc(id)
            .collection(Constants.dstiCollections)
            .doc(assessmentModel.id)
            .set(assessmentModel.toJson());
        // save to user's database end.
      }
    } else {
      // add organisationID
      assessmentModel.organisationID = _organisationID;

      if (_pdfHeading == Constants.riskAssessment) {
        // save to organisation's database
        await _organisationCollection
            .doc(_organisationID)
            .collection(Constants.assessmentCollection)
            .doc(assessmentModel.id)
            .set(assessmentModel.toJson());
      } else {
        // save to organisation's database
        await _organisationCollection
            .doc(_organisationID)
            .collection(Constants.dstiCollections)
            .doc(assessmentModel.id)
            .set(assessmentModel.toJson());
      }
    }

    notifyListeners();
  }

  // open pdf assessment file
  Future<void> openPdf(String url, String filename) async {
    _isLoading = true;
    notifyListeners();

    try {
      await PDFHandler.openPDF(url, filename);
    } catch (e) {
      print("Error opening PDF: $e");
      // Handle error (e.g., show an error message to the user)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // delete pdf from local storage
  Future<void> deletePdf(String filename) async {
    await PDFHandler.deleteFile(filename);
  }

  // Method to check if a PDF is downloaded
  Future<bool> isPdfDownloaded(String filename) async {
    return await PDFHandler.getDownloadStatus(filename);
  }

  // set has signed
  void setHasSigned(bool hasSigned) {
    _hasSigned = hasSigned;
    notifyListeners();
  }

  // save the signature image
  Future<void> saveSignature() async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);
    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    _signatureImage = bytes!.buffer.asUint8List();
    // return has signed back to false
    _hasSigned = false;
    notifyListeners();
  }

  void resetSignature() {
    _signatureImage = null;
    // return has signed back to false
    _hasSigned = false;
    notifyListeners();
  }

  // set weather
  void setWeather({required Weather newWeather}) {
    _weather = newWeather;
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

  // get labels from ppeModelList
  List<String> getPpeLabels() {
    return _ppeModelList.map((ppe) => ppe.label).toList();
  }

  // remove item from list
  Future<void> removeItem({
    required ListHeader label,
    required String data,
  }) async {
    switch (label) {
      case ListHeader.equipments:
        _assessmentModel.equipments.remove(data);
        notifyListeners();
        break;
      case ListHeader.hazards:
        _assessmentModel.hazards.remove(data);
        notifyListeners();
        break;
      case ListHeader.risks:
        _assessmentModel.risks.remove(data);
        notifyListeners();
        break;
      case ListHeader.control:
        _assessmentModel.control.remove(data);
        notifyListeners();
        break;
      default:
        break;
    }
  }

  // remove item from list
  Future<void> removeDataItem({
    required String label,
    required String data,
  }) async {
    switch (label) {
      case 'Equipments':
        _assessmentModel.equipments.remove(data);
        notifyListeners();
        break;
      case 'Hazards':
        _assessmentModel.hazards.remove(data);
        notifyListeners();
        break;
      case 'Risks':
        _assessmentModel.risks.remove(data);
        notifyListeners();
        break;
      case 'Control Measures':
        _assessmentModel.control.remove(data);
        notifyListeners();
        break;
      default:
        break;
    }
  }

  // add ppe model item
  void addOrRemovePpeModelItem({required PpeModel ppeItem}) {
    // check ppeModelList contains ppeItem
    if (_ppeModelList.contains(ppeItem)) {
      // remove ppeItem
      _ppeModelList.remove(ppeItem);

      // remove ppe from assessmentModel
      _assessmentModel.ppe.remove(ppeItem.label);
    } else {
      _ppeModelList.add(ppeItem);

      //  add ppe to assessmentModel
      _assessmentModel.ppe.add(ppeItem.label);
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
    ImagePickerHandler.imagePickerAnimatedDialog(
      context: context,
      title: 'Select Photo',
      content: 'Choose an Option',
      onPressed: (value) {
        selectImages(
          fromCamera: value,
          onError: (String error) {
            if (context.mounted) {
              showSnackBar(context: context, message: error);
            }
          },
        );
      },
    );
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
    notifyListeners();
  }

  Future<void> submitPrompt({
    required String creatorID,
    required String orgID,
    required String description,
    required String docTitle,
  }) async {
    _isLoading = true;
    notifyListeners();

    // get model to use text or vision
    //var model = await GeminiService.getModel(images: _maxImages);
    var model = await _modelManager.getModel(
      isVision: _maxImages < 10,
      isDocumentSpecific: true,
    );

    // set description to use in prompt
    await setDocData(
      description,
      creatorID,
      orgID,
      docTitle,
    );

    // get promptDara
    final prompt = getPromptData();

    try {
      final content = await _modelManager.generateContent(model, prompt);

      // handle no image or image of not-food
      if (content.text != null && content.text!.contains(noRiskFound)) {
        // show error message
        _isLoading = false;
      } else {
        final List<String> images = [];
        if (_imagesFileList != null) {
          for (var image in _imagesFileList!) {
            images.add(image.path);
          }
        }
        final assessmentId = const Uuid().v4();
        _assessmentModel = AssessmentModel.fromGeneratedContent(
          content,
          assessmentId,
          creatorID,
          _organisationID,
          _weather.name,
          _assessmentModel.ppe,
          images,
          DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
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
The weather is: ${_weather.name}

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
Return the assessment as valid JSON using the following structure:
{
  "title": \$assessmentTitle,
  "taskToAchieve": \$taskToAchieve,
  "equipments": \$equipments,
  "hazards": \$hazards,
  "risks": \$risks,
  "control": \$control,
  "summary": \$summary,
}
  
equipments, hazards and risks should be of type List<String> with a max length of 10 or less.
''';

  Future<void> submitTestAssessment({
    required String creatorID,
    required String orgID,
    required String docTitle,
  }) async {
    _isLoading = true;
    await setDocData(
      description,
      creatorID,
      orgID,
      docTitle,
    );
    final List<String> images = [];
    notifyListeners();
    if (_imagesFileList != null) {
      for (var image in _imagesFileList!) {
        images.add(image.path);
      }
    }
    final assessmentId = const Uuid().v4();
    _assessmentModel = AssessmentModel.fromTestString(
      testAssessment,
      assessmentId,
      creatorID,
      organisationID,
      _weather.name,
      _assessmentModel.ppe,
      images,
      DateTime.now(),
    );
    _isLoading = false;
    notifyListeners();
  }

  final testAssessment = '''
{
        "id": "50807458-2475-4134-8402-000000000001",
        "title": "Clearing of Rubble",
        "taskToAchieve": "To clear rubble from the site",
        "equipments": [
          "gloves",
          "boots",
          "hard hat",
          "safety glasses",
          "respirator",
          "shovel",
          "rake",
          "wheelbarrow",
          "dump truck"
        ],
        "hazards": [
          "sharp objects",
          "heavy objects",
          "dust",
          "noise",
          "vibration",
          "heat",
          "lightning",
          "fire",
          "electricity",
          "hazardous materials"
        ],
        "risks": [
          "cuts",
          "bruises",
          "back injuries",
          "head injuries",
          "respiratory problems",
          "hearing loss",
          "heat stress",
          "electrocution",
          "burns",
          "chemical exposure"
        ],
        "control": [
          "follow all safety procedures",
          "use the buddy system",
          "take breaks often",
          "stay hydrated",
          "dress appropriately for the weather",
          "be careful of sharp objects",
          "be careful of heavy objects",
          "be careful of dust",
          "be careful of heat",
          "be careful of hazardous materials"
        ],
        "summary": "The risk assessment has been completed for the task of clearing rubble from the site. The hazards and risks have been identified and control measures have been proposed. The risks are low and can be mitigated by following the control measures."
      }
''';
}
