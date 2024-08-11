import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/api/pdf_api.dart';
import 'package:gemini_risk_assessor/api/pdf_handler.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/models/prompt_data_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:gemini_risk_assessor/firebase/error_handler.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class AssessmentProvider extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  List<PpeModel> _ppeModelList = [];
  List<XFile>? _imagesFileList = [];
  bool _isLoading = false;
  int _maxImages = 5;
  int _numberOfPeople = 1;
  String _description = '';
  String _pdfHeading = '';
  AssessmentModel _assessmentModel =
      AssessmentModel.fromJson(<String, dynamic>{});
  Weather _weather = Weather.sunny;
  bool _hasSigned = false;
  String _groupID = '';
  String _uid = '';

  String? _safetyFileContent;
  bool _useSafetyFile = false;

  // getters
  List<PpeModel> get ppeModelList => _ppeModelList;
  List<XFile>? get imagesFileList => _imagesFileList;
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  int get numberOfPeople => _numberOfPeople;
  String get description => _description;
  AssessmentModel get assessmentModel => _assessmentModel;
  Weather get weather => _weather;
  bool get hasSigned => _hasSigned;
  String get groupID => _groupID;
  String get uid => _uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);
  final CollectionReference _groupsCollection =
      FirebaseFirestore.instance.collection(Constants.groupsCollection);

  Future<void> setDocData(
    String desc,
    String creatorID,
    String groupID,
    String docTitle,
  ) async {
    _description = desc;
    _uid = creatorID;
    _groupID = groupID;
    _pdfHeading = docTitle;
    notifyListeners();
  }

  // set loading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> createPdfAndSave(
    String pdfHeading,
    AssessmentModel? assessmentData,
    Function(String) onError,
  ) async {
    // set loading
    _isLoading = true;
    notifyListeners();

    final assessment = assessmentData ?? _assessmentModel;

    try {
      final creatorName = await getCreatorName(assessment.createdBy);

      // Check if the PDF already exists
      final folderName = 'RiskAssessments';
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = path.join(directory.path, folderName);
      final fileName = '${assessment.id}.pdf';
      final filePath = path.join(dirPath, fileName);
      final file = File(filePath);

      if (await file.exists()) {
        // If the file exists, open it
        await PDFHandler.openPDF(file.path, fileName);
      } else {
        // Generate PDF
        final pdfFile = await PdfApi.generatePdf(
          assessmentModel: assessment,
          heading: pdfHeading,
          creatorName: creatorName,
        );

        // Open the generated PDF
        await PDFHandler.openPDF(pdfFile.path, fileName);
      }
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error creating PDF');
      // Reset loading state
      _isLoading = false;
      notifyListeners();
      // Handle any errors
      onError(e.toString());
    } finally {
      // Reset loading state
      _isLoading = false;
      notifyListeners();
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
  Future<void> saveDataToFirestore() async {
    final id = _groupID.isNotEmpty ? _groupID : _uid;

    if (_assessmentModel.images.isNotEmpty) {
      List<String> imagesUrls = [];
      for (var image in _assessmentModel.images) {
        final imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
          file: File(image),
          reference:
              '${Constants.images}/${Constants.assessmentCollection}/$id/${DateTime.now().toIso8601String()}${path.extension(image)}',
        );
        imagesUrls.add(imageUrl);
      }

      _assessmentModel.images = imagesUrls;
    }

    if (_groupID.isEmpty) {
      // save to user's database
      await _usersCollection
          .doc(id)
          .collection(Constants.assessmentCollection)
          .doc(assessmentModel.id)
          .set(assessmentModel.toJson());
    } else {
      // add groupID
      assessmentModel.groupID = _groupID;

      // save to group's database
      await _groupsCollection
          .doc(_groupID)
          .collection(Constants.assessmentCollection)
          .doc(assessmentModel.id)
          .set(assessmentModel.toJson());
    }

    notifyListeners();
  }

  // open pdf assessment file
  Future<void> openPdf({
    required String pdfUrl,
    required String fileName,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await PDFHandler.openPDF(pdfUrl, fileName);
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error creating PDF');
      onError(e.toString());
    } finally {
      onSuccess();
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

  // add item to list
  Future<void> addDataItem({
    required String label,
    required String data,
  }) async {
    switch (label) {
      case 'Equipments':
        _assessmentModel.equipments.add(data);
        notifyListeners();
        break;
      case 'Hazards':
        _assessmentModel.hazards.add(data);
        notifyListeners();
        break;
      case 'Risks':
        _assessmentModel.risks.add(data);
        notifyListeners();
        break;
      case 'Control Measures':
        _assessmentModel.control.add(data);
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

  // check if we should show reset icon
  bool shouldShowResetIcon() {
    return _ppeModelList.isNotEmpty ||
        _imagesFileList!.isNotEmpty ||
        _numberOfPeople > 1 ||
        weather != Weather.sunny;
  }

  // reset creation data
  void resetCreationData() {
    removeAllImages();
    removeAllPpeModelItems();
    _weather = Weather.sunny;
    _numberOfPeople = 1;
    notifyListeners();
  }

  // remove all ppes from ppeModelList
  void removeAllPpeModelItems() {
    _ppeModelList.clear();
    _assessmentModel.ppe = [];
    notifyListeners();
  }

  // remove all images from imagesFileList
  void removeAllImages() {
    _imagesFileList!.clear();
    _maxImages = 5;
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
    required BuildContext context,
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    ImagePickerHandler.showLoadingDialog(context, 'Selecting image...');
    final returnedFiles = await ImagePickerHandler.pickPromptImages(
      fromCamera: fromCamera,
      maxImages: _maxImages,
      onError: (error) {
        // return error to onError
        onError(error.toString());
      },
    );

    // pop the loading dialog
    Navigator.of(context).pop();
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
            log('err $error ');
            if (context.mounted) {
              //showSnackBar(context: context, message: error);
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
    _maxImages = 5;
    _numberOfPeople = 1;
    _ppeModelList = [];
    notifyListeners();
  }

  Future<void> submitPrompt({
    required BuildContext context,
    required String creatorID,
    required String groupID,
    required String description,
    required String docTitle,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    if (groupID.isEmpty) {
      // get user safety settings
      final userProvider = context.read<AuthenticationProvider>().userModel!;
      _useSafetyFile = userProvider.useSafetyFile;
      _safetyFileContent = userProvider.safetyFileContent;
    } else {
      // get group safety settings
      final groupProvider = context.read<GroupProvider>();
      final group = groupProvider.groupModel;
      _useSafetyFile = group.useSafetyFile;
      _safetyFileContent = group.safetyFileContent;
    }

    _isLoading = true;
    notifyListeners();

    // get model to use text or vision
    //var model = await GeminiService.getModel(images: _maxImages);
    var model = await _modelManager.createModel();

    // set description to use in prompt
    await setDocData(
      description,
      creatorID,
      groupID,
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
        onError(noRiskFound);
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
          _groupID,
          _weather.name,
          _assessmentModel.ppe,
          images,
          DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        onSuccess();
      }
    } catch (e, stack) {
      ErrorHandler.recordError(e, stack, reason: 'Error generating content');
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  String get mainPrompt {
    String basePrompt = '''
You are a highly experienced Safety Officer specializing in comprehensive risk assessments across various industries. Your task is to generate a detailed $_pdfHeading based on the provided information. Follow these guidelines:

1. Risk Identification:
   - If no images are provided or if the information does not contain any identifiable risks, respond exactly with: $noRiskFound
   - Focus solely on real, practical risks directly related to the described scenario
   - Consider risks to personnel, equipment, and the environment

2. Assessment Components:
   - Task Description: Clearly define the task or activity being assessed
   - Hazard Identification: List all potential hazards associated with the task
   - Risk Analysis: Evaluate the likelihood and potential severity of each hazard
   - Control Measures: Propose specific, practical mitigation strategies for each identified risk

3. Contextual Factors:
   - Number of people involved: $_numberOfPeople
   - Weather conditions: ${_weather.name}
   - Consider how these factors might influence or exacerbate potential risks

4. Equipment and Tools:
   - Recommend necessary equipment and tools for safe task completion
   - Highlight any specific safety features or requirements for recommended equipment

5. Personal Protective Equipment (PPE):
   - Suggest appropriate PPE beyond what's already listed: ${getSelectedPpe.toString()}
   - Explain the importance of each suggested PPE item in relation to identified risks

6. Environmental Considerations:
   - Assess potential environmental impacts of the task
   - Propose measures to minimize environmental harm

7. Regulatory Compliance:
   - Reference relevant safety standards, regulations, or industry best practices
   - Ensure all recommendations align with current safety guidelines

8. Summary:
   - Provide a concise overview of key risks and critical control measures
   - Emphasize the most crucial safety points for the assessed task

Additional Context:
${_description.isNotEmpty ? _description : 'No additional context provided.'}

Remember to focus on practical, relevant risks and mitigation strategies. Avoid generic statements or risks not directly applicable to the described scenario.
''';

    if (_useSafetyFile && _safetyFileContent != null) {
      basePrompt += '''
Incorporate the following user-provided safety guidelines into your assessment:
$_safetyFileContent
Integrate these guidelines where applicable, ensuring they complement and do not contradict general safety standards and regulations.
''';
    }

    return basePrompt;
  }

  static String noRiskFound =
      "No risks identified based on information provided";

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
  
equipments, hazards and risks should be of type List<String>
''';
}
