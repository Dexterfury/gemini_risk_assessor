class Constants {
  // app name
  static const String appName = 'Gemini Risk Assessor';

  // risk assessment
  static const String riskAssessments = 'Risk Assessments';

  // search
  static const String search = 'Search';

  // user model constants
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String imageUrl = 'imageUrl';
  static const String createdAt = 'createdAt';

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
