import 'package:gemini_risk_assessor/constants.dart';

class UserModel {
  String uid;
  String name;
  String phone;
  String imageUrl;
  String createdAt;

  // constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.imageUrl,
    required this.createdAt,
  });

  // factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json[Constants.uid] ?? '',
      name: json[Constants.name] ?? '',
      phone: json[Constants.phone] ?? '',
      imageUrl: json[Constants.imageUrl] ?? '',
      createdAt: json[Constants.createdAt] ?? '',
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.phone: phone,
      Constants.imageUrl: imageUrl,
      Constants.createdAt: createdAt,
    };
  }
}
