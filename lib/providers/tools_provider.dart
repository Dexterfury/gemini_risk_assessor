import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:image_picker/image_picker.dart';

class ToolsProvider extends ChangeNotifier {
  bool _isLoading = false;
  int _maxImages = 10;
  String _description = '';
  File? _pdfToolFile;
  String _uid = '';
  List<XFile>? _imagesFileList = [];
  ToolModel? _toolModel;

  // getters
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  String get description => _description;
  File? get pdfToolFile => _pdfToolFile;
  List<XFile>? get imagesFileList => _imagesFileList;
  ToolModel? get toolModel => _toolModel;
}
