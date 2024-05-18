import 'package:gemini_risk_assessor/constants.dart';

class UserModel {
  String uid;
  String name;
  String email;
  String imageUrl;
  String createdAt;

  // constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
  });

  // factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json[Constants.uid] ?? '',
      name: json[Constants.name] ?? '',
      email: json[Constants.email] ?? '',
      imageUrl: json[Constants.imageUrl] ?? '',
      createdAt: json[Constants.createdAt] ?? '',
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.email: email,
      Constants.imageUrl: imageUrl,
      Constants.createdAt: createdAt,
    };
  }
}
