import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gemini_risk_assessor/constants.dart';

class ChatPromptDataModel {
  List<XFile> images;
  String textInput;

  // constructor
  ChatPromptDataModel({
    required this.images,
    required this.textInput,
  });

  // toJson method
  factory ChatPromptDataModel.fromJson(Map<String, dynamic> json) {
    return ChatPromptDataModel(
      images: json[Constants.images] ?? [],
      textInput: json[Constants.textInput] ?? '',
    );
  }

  // copy with method
  ChatPromptDataModel copyWith({
    List<XFile>? images,
    String? textInput,
  }) {
    return ChatPromptDataModel(
      images: images ?? this.images,
      textInput: textInput ?? this.textInput,
    );
  }
}
