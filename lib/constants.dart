import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/help/ai_tips_help_details.dart';
import 'package:gemini_risk_assessor/help/dsti_help_details.dart';
import 'package:gemini_risk_assessor/help/help_item.dart';
import 'package:gemini_risk_assessor/help/navigation_help_details.dart';
import 'package:gemini_risk_assessor/help/organisation_help_details.dart';
import 'package:gemini_risk_assessor/help/risk_assessment_help_details.dart';
import 'package:gemini_risk_assessor/help/tools_help_details.dart';
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
    return heading == riskAssessment ? 'RiskAssessments' : 'Dstis';
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
  static const String createOrganizationRoute = '/createOrganization';
  static const String chatRoute = '/chat';

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
  static const String discussingAbout = 'discussingAbout';

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
  static const String organizationID = 'organizationID';
  static const String pdfUrl = 'pdfUrl';
  static const String isShared = 'isShared';

  static const String orgArg = 'orgArg';

  static const String shareWithTitle = 'Shared With';
  static const String sharedWith = 'sharedWith';
  static const String discussions = 'Discussions';

  // organization model constants
  static const String creatorUID = 'creatorUID';
  static const String aboutOrganization = 'aboutOrganization';
  static const String address = 'address';
  static const String emailAddress = 'emailAddress';
  static const String websiteURL = 'websiteURL';
  static const String organizationTerms = 'organizationTerms';
  static const String awaitingApprovalUIDs = 'awaitingApprovalUIDs';
  static const String membersUIDs = 'membersUIDs';
  static const String adminsUIDs = 'adminsUIDs';
  static const String requestToReadTerms = 'requestToReadTerms';
  static const String allowSharing = 'allowSharing';

  static const String enterYourName = 'Enter your name';
  static const String organizationName = 'Enter name';
  static const String signInToAutoFillName = 'Sign In to auto fill name';
  static const String enterDescription = 'Enter description';
  static const String enterTerms = 'Organization terms';
  static const String termsOptional = 'Enter organization terms (optional)';

  static const String changeName = 'Change Name';
  static const String changeDescription = 'Change Description';

  // firestore collections
  static const String usersCollection = 'users';
  static const String promptCollection = 'prompts';
  static const String assessmentCollection = 'assessments';
  static const String organizationCollection = 'organizations';
  static const String toolsCollection = 'tools';
  static const String dstiCollections = 'dsti';
  static const String chatsCollection = 'chats';
  static const String toolsChatsCollection = 'toolsChats';
  static const String assessmentsChatsCollection = 'assessmentsChats';
  static const String dstisChatsCollection = 'dstisChats';
  static const String chatDataCollection = 'chatData';
  static const String notificationsCollection = 'notifications';
  static const String discussionsCollection = 'discussions';

  static const String organizationImage = 'organizationImage';

  static const String exitSuccessful = 'Exit Successful';
  static const String exitFailed = 'Exit Failed';
  static const String deletedSuccessfully = 'Deleted successfully';

  // message constants
  static const String messageID = 'messageID';
  static const String chatID = 'chatID';
  static const String senderID = 'senderID';
  static const String question = 'question';
  static const String answer = 'answer';
  static const String imagesUrls = 'imagesUrls';
  static const String reactions = 'reactions';
  static const String sentencesUrls = 'sentencesUrls';
  static const String finalWords = 'finalWords';
  static const String timeSent = 'timeSent';

  // shared preferences keys
  static const String voiceIndex = 'voiceIndex';
  static const String volume = 'volume';
  static const String audioSpeed = 'audioSpeed';
  static const String shouldSpeak = 'ShouldSpeak';

  // notification constants
  static const String recieverUID = 'recieverUID';
  static const String notificationType = 'notificationType';
  static const String wasClicked = 'wasClicked';
  static const String notificationDate = 'notificationDate';

  // notification types
  static const String notificationID = 'notificationID';
  static const String dstiNotification = 'DSTI_NOTIFICATION';
  static const String assessmentNotification = 'ASSESSMENT_NOTIFICATION';
  static const String toolsNotification = 'TOOLS_NOTIFICATION';
  static const String organizationInvitation = 'ORGANIZATION_INVITATION';
  static const String requestNotification = 'REQUEST_NOTIFICATION';
  static const String descussNotification = 'DESCUSS_NOTIFICATION';

  // dialog content
  static const String loading = 'loading';
  static const String signature = 'signature';

  // default description
  static const String defaultDescription = 'Organization Description';

  static String getDoctTitle(String docTitle) {
    if (docTitle == createAssessment) {
      return riskAssessment;
    } else {
      return dailySafetyTaskInstructions;
    }
  }

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

  // helper items
  static final List<HelpItem> helpItems = [
    HelpItem(
      title: 'Creating a DSTI',
      description: 'Learn how to create a Daily Safety Task Instruction',
      detailScreen: const DstiHelpDetails(),
    ),
    HelpItem(
      title: 'Risk Assessments',
      description: 'Understanding and creating Risk Assessments',
      detailScreen: const RiskAssessmentHelpDetails(),
    ),
    HelpItem(
      title: 'Tools Explainer',
      description: 'How to use the Tools feature effectively',
      detailScreen: const ToolsHelpDetails(),
    ),
    HelpItem(
      title: 'Organization Management',
      description: 'Managing and interacting with organizations',
      detailScreen: const OrganizationHelpDetails(),
    ),
    HelpItem(
      title: 'AI Integration Tips',
      description: 'Get the most out of AI-generated content',
      detailScreen: const AiTipsHelpDetails(),
    ),
    HelpItem(
      title: 'App Navigation',
      description: 'Learn how to navigate the app efficiently',
      detailScreen: const NavigationHelpDetails(),
    ),
  ];

  // build section for helper classes
  static Widget buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 16))),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }
}
