import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Log a custom event
  static Future logCustomEvent(String eventName,
      {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // Log when a screen is viewed
  static Future logScreenView(
      {required String screenName, required String screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Log when a user signs in
  static Future logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // Log when a user creates an account
  static Future logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Log when a user starts a risk assessment
  static Future logStartRiskAssessment() async {
    await logCustomEvent('start_risk_assessment');
  }

  // Log when deleting assessment for group
  static Future logDeletingAssessment() async {
    await logCustomEvent('deleting_assessment');
  }

  // Log when a user completes a risk assessment
  static Future logCompleteRiskAssessment({int? timeSpentSeconds}) async {
    Map<String, Object> parameters = {};
    if (timeSpentSeconds != null) {
      parameters['time_spent_seconds'] = timeSpentSeconds;
    }
    await logCustomEvent('complete_risk_assessment', parameters: parameters);
  }

  // Log when a user creates a tool explainer
  static Future logCreateToolExplainer() async {
    await logCustomEvent('create_tool_explainer');
  }

  // Log when a user reports a near miss
  static Future logReportNearMiss() async {
    await logCustomEvent('report_near_miss');
  }

  // Log when a user joins a group
  static Future logJoinGroup(String groupName) async {
    await logCustomEvent('join_group', parameters: {
      'group_name': groupName,
    });
  }

  // Log when a user generates an AI quiz
  static Future logGenerateAIQuiz(String assessmentOrToolName) async {
    await logCustomEvent('generate_ai_quiz', parameters: {
      'source': assessmentOrToolName,
    });
  }

  // Set user properties
  static Future setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
