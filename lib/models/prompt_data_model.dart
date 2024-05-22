import 'package:gemini_risk_assessor/constants.dart';
import 'package:image_picker/image_picker.dart';

class PromptDataModel {
  List<XFile> images;
  String textInput;
  String numberOfPeople;
  String selectedPpe;
  List<String> additionalTextInputs;

  // constructor
  PromptDataModel({
    required this.images,
    required this.textInput,
    required this.numberOfPeople,
    required this.selectedPpe,
    required this.additionalTextInputs,
  });

  // toJson method
  factory PromptDataModel.fromJson(Map<String, dynamic> json) {
    return PromptDataModel(
      images: json[Constants.images] ?? [],
      textInput: json[Constants.textInput] ?? '',
      numberOfPeople: json[Constants.numberOfPeople] ?? '',
      selectedPpe: json[Constants.selectedPpe] ?? '',
      additionalTextInputs: json[Constants.additionalTextInputs] ?? [],
    );
  }

  // copy with method
  PromptDataModel copyWith(
      {List<XFile>? images,
      String? textInput,
      String? numberOfPlayers,
      String? selectedPpe,
      List<String>? additionalTextInputs}) {
    return PromptDataModel(
      images: images ?? this.images,
      textInput: textInput ?? this.textInput,
      numberOfPeople: numberOfPlayers ?? this.numberOfPeople,
      selectedPpe: selectedPpe ?? this.selectedPpe,
      additionalTextInputs: additionalTextInputs ?? this.additionalTextInputs,
    );
  }
}
