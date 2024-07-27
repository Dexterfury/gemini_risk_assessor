import 'package:gemini_risk_assessor/constants.dart';

class ControlMeasure {
  final String measure;
  final String type;
  final String reason;

  ControlMeasure({
    required this.measure,
    required this.type,
    required this.reason,
  });

  // Factory constructor to create a ControlMeasure from a Map
  factory ControlMeasure.fromMap(Map<String, dynamic> data) {
    return ControlMeasure(
      measure: data[Constants.measure] ?? '',
      type: data[Constants.type] ?? '',
      reason: data[Constants.reason] ?? '',
    );
  }

  // Convert the ControlMeasure to a Map
  Map<String, dynamic> toMap() {
    return {
      Constants.measure: measure,
      Constants.type: type,
      Constants.reason: reason,
    };
  }
}
