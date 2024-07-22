import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/near_miss_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class NearMissProvider extends ChangeNotifier {
  List<XFile>? _imagesFileList = [];
  bool _isLoading = false;
  int _maxImages = 10;
  NearMissModel? _nearMiss;

  // getters and setters
  List<XFile>? get imagesFileList => _imagesFileList;
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  NearMissModel? get nearMiss => _nearMiss;

  // Initialize default empty model
  Future<void> initializeDefaultModel() async {
    final uuid = Uuid();
    _nearMiss = NearMissModel(
      id: uuid.v4(),
      title: '',
      description: '',
      images: [],
      sharedWith: [],
      reactions: [],
      createdBy: '', // You might want to set this to the current user's ID
      organizationID:
          '', // You might want to set this to the current organization's ID
      createdAt: DateTime.now().toIso8601String(),
    );
    notifyListeners();
  }

  // Method to update the model
  void updateNearMiss(NearMissModel updatedModel) {
    _nearMiss = updatedModel;
    notifyListeners();
  }

  // Method to clear the model
  void clearNearMiss() {
    _nearMiss = null;
    _imagesFileList = [];
    notifyListeners();
  }
}
