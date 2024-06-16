import 'dart:ui';

class Constants {
  // app name
  static const String appName = 'Gemini Risk Assessor';

  // risk assessment
  static const String riskAssessments = 'Risk Assessments';

  // daily task instructions
  static const String dailyTaskInstructions = 'Daily Task Instructions';

  // search
  static const String search = 'Search';

  // create assessment
  static const String createAssessment = 'Create Assessment';

  // navigation routes
  static const String homeRoute = '/home';
  static const String createAssessmentRoute = '/createAssessment';
  static const String assessmentDetailsRoute = '/assessmentDetails';
  static const String profileRoute = '/profile';
  static const String logingRoute = '/login';
  static const String landingRoute = '/landing';
  static const String userInformationRoute = '/userInformation';
  static const String screensControllerRoute = '/screensController';

  static const String verificationId = 'verificationId';
  static const String phoneNumber = 'phoneNumber';

  // user model constants
  static const String uid = 'uid';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String imageUrl = 'imageUrl';
  static const String createdAt = 'createdAt';

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

  static const String enterYourName = 'Enter your name';
  static const String signInToAutoFillName = 'Sign In to auto fill name';
  static const String enterDescription = 'Enter Description';

  // firestore collections
  static const String usersCollection = 'users';
  static const String promptsCollection = 'prompts';
  static const String assessmentsCollection = 'assessments';

  // dummy list of risk assessments
  static const List<Map<String, dynamic>> riskAssessmentsList = [
    {
      'title': 'Risk Assessment 1',
      'description': 'This is the first risk assessment',
    },
    {
      'title': 'Risk Assessment 2',
      'description': 'This is the second risk assessment'
    },
    {
      'title': 'Risk Assessment 3',
      'description': 'This is the third risk assessment',
    },
    {
      'title': 'Risk Assessment 4',
      'description': 'This is the fourth risk assessment',
    }
  ];
}
