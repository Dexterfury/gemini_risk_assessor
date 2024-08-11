import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/error_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class FileUploadHandler {
  static const int _maxSafetyFileSize = 2 * 1024 * 1024; // 2 MB
  static const int _maxSafetyFileChars = 400000; // 400k characters
  static const int _minSafetyFileWords = 1000; // 1000 words

  static const List<String> _safetyKeywords = [
    'safety',
    'hazard',
    'risk',
    'protection',
    'regulation',
    'guideline',
    'precaution',
    'emergency',
    'procedure',
    'protocol',
    'ppe',
    'equipment',
    'training',
    'inspection',
    'compliance'
  ];

  static Future<String> uploadFileAndGetUrl({
    required File file,
    required String reference,
  }) async {
    try {
      final String extension = path.extension(file.path).toLowerCase();
      File fileToUpload;

      if (extension == '.pdf') {
        fileToUpload = file;
      } else if (['.jpg', '.jpeg', '.png'].contains(extension)) {
        fileToUpload = await compressAndGetFile(
          file: file,
          targetPath: file.path.replaceAll(extension, '_compressed$extension'),
        );
      } else {
        throw UnsupportedError('Unsupported file type: $extension');
      }

      String downloadUrl = await storeFileToStorage(
        file: fileToUpload,
        reference: reference,
      );
      return downloadUrl;
    } catch (e, stackTrace) {
      ErrorHandler.recordError(
        e,
        stackTrace,
        reason: 'Failed to upload file and get URL',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }

  static Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    try {
      if (!file.existsSync()) {
        throw FileSystemException("File does not exist", file.path);
      }

      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(reference).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String fileUrl = await taskSnapshot.ref.getDownloadURL();
      return fileUrl;
    } catch (e, stackTrace) {
      ErrorHandler.recordError(
        e,
        stackTrace,
        reason: 'Failed to store file to storage',
        severity: ErrorSeverity.high,
      );
      rethrow;
    }
  }

  static Future<File> compressAndGetFile({
    required File file,
    required String targetPath,
  }) async {
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 90,
      );

      if (result == null) {
        throw Exception("Failed to compress image");
      }

      return File(result.path);
    } catch (e, stackTrace) {
      ErrorHandler.recordError(
        e,
        stackTrace,
        reason: 'Failed to compress image file',
        severity: ErrorSeverity.medium,
      );
      rethrow;
    }
  }

  // Update image in Firestore with error handling
  static Future<String> updateImage({
    required File file,
    required bool isUser,
    required String id,
    required String reference,
  }) async {
    try {
      final imageURL = await uploadFileAndGetUrl(
        file: file,
        reference: reference,
      );
      if (isUser) {
        await FirebaseAuth.instance.currentUser!.updatePhotoURL(imageURL);
        await FirebaseFirestore.instance
            .collection(Constants.usersCollection)
            .doc(id)
            .update({Constants.imageUrl: imageURL});
      } else {
        await FirebaseFirestore.instance
            .collection(Constants.groupsCollection)
            .doc(id)
            .update({Constants.imageUrl: imageURL});
      }

      return imageURL;
    } catch (e, stackTrace) {
      ErrorHandler.recordError(
        e,
        stackTrace,
        reason: 'Failed to update image in Firestore',
        severity: ErrorSeverity.high,
      );
      rethrow;
    }
  }

  static Future<(String, String)> uploadSafetyFile({
    required BuildContext context,
    required File file,
    required String collectionID,
  }) async {
    final fileSize = await file.length();
    String? _safetyFileUrl;
    String? _safetyFileContent;

    if (fileSize > _maxSafetyFileSize) {
      showSnackBar(
        context: context,
        message: 'File size exceeds the maximum limit of 2 MB',
      );
      return ('', '');
    }

    if (path.extension(file.path).toLowerCase() != '.pdf') {
      showSnackBar(
        context: context,
        message: 'Only PDF files are supported',
      );
      return ('', '');
    }

    try {
      final reference = 'safety_files/$collectionID.pdf';
      _safetyFileUrl = await uploadFileAndGetUrl(
        file: file,
        reference: reference,
      );

      // Extract text content from PDF
      final pdfBytes = await file.readAsBytes();
      final pdfDocument = PdfDocument(inputBytes: pdfBytes);
      final pdfTextExtractor = PdfTextExtractor(pdfDocument);
      _safetyFileContent = pdfTextExtractor.extractText();
      pdfDocument.dispose();

      if (_safetyFileContent.length > _maxSafetyFileChars) {
        showSnackBar(
          context: context,
          message:
              'File content exceeds the maximum limit of 400,000 characters',
        );
        // dele the uploaded file
        await FirebaseStorage.instance.ref(reference).delete();
        return ('', '');
      }

      final wordCount = _safetyFileContent.split(RegExp(r'\s+')).length;
      if (wordCount < _minSafetyFileWords) {
        showSnackBar(
          context: context,
          message:
              'File content is too short. Minimum word count is $_minSafetyFileWords',
        );
        return ('', '');
      }

      // Validate safety content
      if (!_containsSafetyContent(_safetyFileContent)) {
        showSnackBar(
          context: context,
          message:
              'The uploaded file does not appear to contain relevant safety information',
        );
        return ('', '');
      }

      return (_safetyFileUrl, _safetyFileContent);
    } catch (e, stackTrace) {
      ErrorHandler.recordError(
        e,
        stackTrace,
        reason: 'Failed to upload safety file',
        severity: ErrorSeverity.medium,
      );
      return ('', '');
    }
  }

  static bool _containsSafetyContent(String content) {
    content = content.toLowerCase();
    int keywordCount = 0;
    for (var keyword in _safetyKeywords) {
      if (content.contains(keyword)) {
        keywordCount++;
      }
    }
    // Require at least 3 unique safety keywords to be present
    return keywordCount >= 3;
  }
}
