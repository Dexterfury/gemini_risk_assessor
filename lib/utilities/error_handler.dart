import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void recordError(dynamic exception, StackTrace stack,
      {String? reason}) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance
          .recordError(exception, stack, reason: reason);
    } else {
      // In debug mode, print to console
      print('Error: $exception');
      print('Stack trace: $stack');
      if (reason != null) {
        print('Reason: $reason');
      }
    }
  }
}
