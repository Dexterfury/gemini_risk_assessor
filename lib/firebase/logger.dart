import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class Logger {
  static void log(String message, {String? tag}) {
    final logMessage = tag != null ? '[$tag] $message' : message;

    // Always print to console
    print(logMessage);

    // In release mode, also log to a service (e.g., Firebase Analytics)
    if (kReleaseMode) {
      FirebaseAnalytics.instance.logEvent(
        name: 'app_log',
        parameters: {
          'message': logMessage,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }
}
