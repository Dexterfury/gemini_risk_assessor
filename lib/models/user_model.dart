import 'package:gemini_risk_assessor/constants.dart';

class UserModel {
  String uid;
  String name;
  String phone;
  String email;
  String imageUrl;
  String token;
  String aboutMe;
  String createdAt;

  // constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.token,
    required this.aboutMe,
    required this.createdAt,
  });

  // factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json[Constants.uid] ?? '',
      name: json[Constants.name] ?? '',
      phone: json[Constants.phone] ?? '',
      email: json[Constants.email] ?? '',
      imageUrl: json[Constants.imageUrl] ?? '',
      token: json[Constants.token] ?? '',
      aboutMe: json[Constants.aboutMe] ?? '',
      createdAt: json[Constants.createdAt] ?? '',
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.phone: phone,
      Constants.email: email,
      Constants.imageUrl: imageUrl,
      Constants.token: token,
      Constants.aboutMe: aboutMe,
      Constants.createdAt: createdAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode {
    return uid.hashCode;
  }
}
