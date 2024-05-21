import 'package:flutter/material.dart';

class PpeModel {
  int id;
  String label;
  Widget icon;

  // constructor
  PpeModel({
    required this.id,
    required this.label,
    required this.icon,
  });

  // comperater
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PpeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
