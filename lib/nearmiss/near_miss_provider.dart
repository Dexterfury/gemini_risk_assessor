import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_model.dart';
import 'package:gemini_risk_assessor/service/gemini_model_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class NearMissProvider extends ChangeNotifier {
  final GeminiModelManager _modelManager = GeminiModelManager();
  List<XFile>? _imagesFileList = [];
  bool _isLoading = false;
  int _maxImages = 10;
  NearMissModel? _nearMiss;

  // getters and setters
  List<XFile>? get imagesFileList => _imagesFileList;
  bool get isLoading => _isLoading;
  int get maxImages => _maxImages;
  NearMissModel? get nearMiss => _nearMiss;

  // create a near miss report
  Future<void> createANearMissReport({
    required String creatorID,
    required String groupID,
    required String description,
    required String dateTime,
    required String location,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final content = await _modelManager.generateNearMissReport(description);

      if (content.text == null) {
        throw Exception('Failed to generate control measures');
      }

      final nearMissID = Uuid().v4();

      final nearMiss = NearMissModel.fromGeneratedContent(
        content,
        nearMissID,
        location,
        description,
        dateTime,
        creatorID,
        groupID,
        DateTime.now(),
      );
    } catch (e) {
      print('Error near miss: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize default empty model
  Future<void> initializeDefaultModel() async {
    final uuid = Uuid();
    _nearMiss = NearMissModel(
      id: uuid.v4(),
      location: '',
      description: '',
      nearMissDateTime: '',
      sharedWith: [],
      reactions: [],
      controlMeasures: [],
      createdBy: '', // You might want to set this to the current user's ID
      groupID: '', // You might want to set this to the current group's ID
      createdAt: DateTime.now(),
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
