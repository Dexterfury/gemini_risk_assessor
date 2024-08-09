import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase/error_handler.dart';
import 'package:path/path.dart' as path;

class FileUploadHandler {
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
}
