import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/nearmiss/control_measure.dart';
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

  // Add a new control measure
  void addControlMeasure(ControlMeasure newMeasure) {
    if (_nearMiss != null) {
      _nearMiss!.controlMeasures.add(newMeasure);
      notifyListeners();
    }
  }

  // Delete a control measure
  void deleteControlMeasure(int index) {
    if (_nearMiss != null && _nearMiss!.controlMeasures.length > index) {
      _nearMiss!.controlMeasures.removeAt(index);
      notifyListeners();
    }
  }

  // Update an existing control measure
  void updateControlMeasure(int index, ControlMeasure updatedMeasure) {
    if (_nearMiss != null && _nearMiss!.controlMeasures.length > index) {
      _nearMiss!.controlMeasures[index] = updatedMeasure;
      notifyListeners();
    }
  }

  // create a near miss report
  Future<void> submitPromptNearMiss({
    required String creatorID,
    required String groupID,
    required String description,
    required String dateTime,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final content = await _modelManager.generateNearMissReport(description);

      if (content.text == null) {
        throw Exception('Failed to generate control measures');
      }

      final nearMissID = Uuid().v4();

      _nearMiss = NearMissModel.fromGeneratedContent(
        content,
        nearMissID,
        description,
        dateTime,
        creatorID,
        groupID,
        DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (error) {
      print('Error near miss: $error');
      _isLoading = false;
      notifyListeners();
      if (error is SocketException) {
        onError(
            "Network error: Unable to connect to the server. Please check your internet connection and try again.");
      } else if (error is TimeoutException) {
        onError("Request timed out. Please try again later.");
      } else if (error is HttpException) {
        onError("HTTP error occurred: ${error.message}");
      } else {
        onError("An unexpected error occurred: ${error.toString()}");
      }

      if (kDebugMode) {
        print('error### : $error');
      }
    }
  }

  // save near miss to firestore
  Future<void> saveNearMiss({
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseMethods.saveNearMiss(
        nearMiss: _nearMiss!,
      );

      _isLoading = false;
      // clear the model
      _nearMiss = null;
      notifyListeners();

      onSuccess();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onError(e.toString());
      log('error log: $e');
    }
  }

  // Initialize default empty model
  Future<void> initializeDefaultModel() async {
    final uuid = Uuid();
    _nearMiss = NearMissModel(
      id: uuid.v4(),
      description: '',
      dateTime: '',
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
  Future<void> updateNearMiss(NearMissModel updatedModel) async {
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
