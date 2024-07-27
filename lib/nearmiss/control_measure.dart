import 'package:gemini_risk_assessor/constants.dart';

class ControlMeasure {
  final String measure;
  final String type;
  final String rationale;

  ControlMeasure({
    required this.measure,
    required this.type,
    required this.rationale,
  });

  // Factory constructor to create a ControlMeasure from a Map
  factory ControlMeasure.fromMap(Map<String, dynamic> data) {
    return ControlMeasure(
      measure: data[Constants.measure] ?? '',
      type: data[Constants.type] ?? '',
      rationale: data[Constants.rationale] ?? '',
    );
  }

  // Convert the ControlMeasure to a Map
  Map<String, dynamic> toMap() {
    return {
      Constants.measure: measure,
      Constants.type: type,
      Constants.rationale: rationale,
    };
  }
}
