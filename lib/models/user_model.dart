import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';

class UserModel extends ChangeNotifier {
  String uid;
  String name;
  String phone;
  String email;
  String imageUrl;
  String token;
  String aboutMe;
  double rating;
  double safetyPoints;
  String safetyFileUrl;
  String safetyFileContent;
  bool useSafetyFile;
  bool isAnonymous;
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
    required this.rating,
    required this.safetyPoints,
    required this.safetyFileUrl,
    required this.safetyFileContent,
    required this.useSafetyFile,
    required this.isAnonymous,
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
      rating: (json[Constants.rating] ?? 0).toDouble(),
      safetyPoints: (json[Constants.safetyPoints] ?? 0).toDouble(),
      safetyFileUrl: json[Constants.safetyFileUrl] ?? '',
      safetyFileContent: json[Constants.safetyFileContent] ?? '',
      useSafetyFile: json[Constants.useSafetyFile] ?? false,
      isAnonymous: json[Constants.isAnonymous] ?? false,
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
      Constants.rating: rating,
      Constants.safetyPoints: safetyPoints,
      Constants.safetyFileUrl: safetyFileUrl,
      Constants.safetyFileContent: safetyFileContent,
      Constants.useSafetyFile: useSafetyFile,
      Constants.isAnonymous: isAnonymous,
      Constants.createdAt: createdAt,
    };
  }

  // copy with method
  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    String? email,
    String? imageUrl,
    String? token,
    String? aboutMe,
    double? rating,
    double? safetyPoints,
    String? safetyFileUrl,
    String? safetyFileContent,
    bool? useSafetyFile,
    bool? isAnonymous,
    String? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      token: token ?? this.token,
      aboutMe: aboutMe ?? this.aboutMe,
      rating: rating ?? this.rating,
      safetyPoints: safetyPoints ?? this.safetyPoints,
      safetyFileUrl: safetyFileUrl ?? this.safetyFileUrl,
      safetyFileContent: safetyFileContent ?? this.safetyFileContent,
      useSafetyFile: useSafetyFile ?? this.useSafetyFile,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
    );
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
