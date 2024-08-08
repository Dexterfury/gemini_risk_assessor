import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/logger.dart';

class ErrorHandler {
  static void recordError(dynamic exception, StackTrace? stack,
      {String? reason, ErrorSeverity severity = ErrorSeverity.medium}) {
    // check if the error is fatal
    bool isFatal = severity == ErrorSeverity.critical;
    // Log the error
    Logger.log('Error: $exception', tag: 'ERROR');
    if (stack != null) {
      Logger.log('Stack trace: $stack', tag: 'ERROR');
    } else {
      Logger.log('No stack trace available', tag: 'ERROR');
    }
    if (reason != null) {
      Logger.log('Reason: $reason', tag: 'ERROR');
    }

    // In release mode, also report to Firebase Crashlytics
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        fatal: isFatal,
      );
    }

    AnalyticsHelper.logCustomEvent('app_error', parameters: {
      'error_message': exception.toString(),
      'reason': reason ?? 'Unknown',
      'severity': severity.toString(),
    });
  }
}
