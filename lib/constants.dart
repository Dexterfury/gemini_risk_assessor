import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';

class Constants {
  // app name
  static const String appName = 'Gemini Risk Assessor';

  // risk assessment
  static const String riskAssessments = 'Risk Assessments';

  // risk assessment
  static const String riskAssessment = 'Risk Assessment';

  // daily safety task instructions
  static const String dailySafetyTaskInstructions =
      'Daily Safety Task Instructions';

  // tools
  static const String tools = 'Tools';

  // daily task instructions
  static const String dailyTaskInstructions = 'Daily Safety Task Instructions';

  // search
  static const String search = 'Search';

  // create assessment
  static const String createAssessment = 'New Assessment';
  static const String createDsti = 'New DSTI';
  static const String toolExplainer = 'Tool Explainer';

  static getFolderName(String heading) {
    return heading == Constants.riskAssessment ? 'RiskAssessments' : 'Dstis';
  }

  // image cache manager keys
  static const String userImageKey = 'userImageKey';
  static const String generatedImagesKey = 'generatedImagesKey';

  // navigation routes
  static const String homeRoute = '/home';
  static const String createAssessmentRoute = '/createAssessment';
  static const String assessmentDetailsRoute = '/assessmentDetails';
  static const String profileRoute = '/profile';
  static const String logingRoute = '/login';
  static const String landingRoute = '/landing';
  static const String userInformationRoute = '/userInformation';
  static const String screensControllerRoute = '/screensController';
  static const String optRoute = '/opt';
  static const String createToolRoute = '/createTool';
  static const String createOrganisationRoute = '/createOrganisation';

  static const String verificationId = 'verificationId';
  static const String phoneNumber = 'phoneNumber';

  // user model constants
  static const String uid = 'uid';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String imageUrl = 'imageUrl';
  static const String token = 'token';
  static const String aboutMe = 'aboutMe';
  static const String createdAt = 'createdAt';
  static const String userModel = 'userModel';
  static const String userImages = 'userImages';

  static const String pdfFiles = 'pdfFiles';
  static const String toolPdf = 'toolPdf';
  static const String description = 'description';

  // constants for promptDataModel
  static const String images = 'images';
  static const String textInput = 'textInput';
  static const String numberOfPeople = 'numberOfPeople';
  static const String selectedPpe = 'selectedPpe';
  static const String additionalTextInputs = 'additionalTextInputs';

  // assessment model constants
  static const String id = 'id';
  static const String title = 'title';
  static const String taskToAchieve = 'taskToAchieve';
  static const String equipments = 'equipments';
  static const String hazards = 'hazards';
  static const String risks = 'risks';
  static const String signatures = 'signatures';
  static const String approvers = 'approvers';
  static const String ppe = 'ppe';
  static const String control = 'control';
  static const String weather = 'weather';
  static const String summary = 'summary';
  static const String createdBy = 'createdBy';
  static const String organisationID = 'organisationID';
  static const String pdfUrl = 'pdfUrl';

  static const String orgArg = 'orgArg';

  // organisation model constants
  static const String creatorUID = 'creatorUID';
  static const String aboutOrganisation = 'aboutOrganisation';
  static const String address = 'address';
  static const String emailAddress = 'emailAddress';
  static const String websiteURL = 'websiteURL';
  static const String awaitingApprovalUIDs = 'awaitingApprovalUIDs';
  static const String membersUIDs = 'membersUIDs';
  static const String adminsUIDs = 'adminsUIDs';

  static const String enterYourName = 'Enter your name';
  static const String organisationName = 'Organisation name';
  static const String signInToAutoFillName = 'Sign In to auto fill name';
  static const String enterDescription = 'Enter description';

  static const String changeName = 'Change Name';
  static const String changeDescription = 'Change Description';

  // firestore collections
  static const String usersCollection = 'users';
  static const String promptCollection = 'prompts';
  static const String assessmentCollection = 'assessments';
  static const String organisationCollection = 'organisations';
  static const String toolsCollection = 'tools';
  static const String dstiCollections = 'dsti';

  static const String organisationImage = 'organisationImage';

  static const String exitSuccessful = 'Exit Successful';
  static const String exitFailed = 'Exit Failed';
  static const String deletedSuccessfully = 'Deleted successfully';

  // list of ppe icons
  static List<PpeModel> getPPEIcons({
    double radius = 20.0,
  }) {
    List<PpeModel> icons = [];
    for (int i = 0; i < ppeAssetsList.length; i++) {
      icons.add(
        PpeModel(
          id: 1 + i,
          label: ppeLabels[i],
          icon: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.blue,
            backgroundImage: AssetImage(ppeAssetsList[i]),
          ),
        ),
      );
    }
    return icons;
  }

  // list of ppe labels
  static List<String> ppeAssetsList = [
    AssetsManager.dustMask,
    AssetsManager.earProtection,
    AssetsManager.faceShield,
    AssetsManager.footProtection,
    AssetsManager.handProtection,
    AssetsManager.headProtection,
    AssetsManager.highVisClothing,
    AssetsManager.lifeJacket,
    AssetsManager.protectiveClothing,
    AssetsManager.safetyGlasses,
    AssetsManager.safetyHarness,
    AssetsManager.other,
  ];
  // list of ppe labels
  static List<String> ppeLabels = [
    'Dust Mask',
    'Ear Protection',
    'Face Shield',
    'Foot Protection',
    'Hand Protection',
    'Head Protection',
    'High Vis Clothing',
    'Life Jacket',
    'Protective Clothing',
    'Safety Glasses',
    'Safety Harness',
    'Other',
  ];
}
