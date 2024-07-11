import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:path/path.dart' as path;

class FileUploadHandler {
  static Future<String> uploadFileAndGetUrl({
    required File file,
    required String reference,
  }) async {
    print("Original file path: ${file.path}");

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

    print("File to upload: ${fileToUpload.path}");
    print("File exists: ${fileToUpload.existsSync()}");
    print("File size: ${fileToUpload.lengthSync()} bytes");

    String downloadUrl = await storeFileToStorage(
      file: fileToUpload,
      reference: reference,
    );
    return downloadUrl;
  }

  static Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    if (!file.existsSync()) {
      throw FileSystemException("File does not exist", file.path);
    }

    UploadTask uploadTask =
        FirebaseStorage.instance.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  static Future<File> compressAndGetFile({
    required File file,
    required String targetPath,
  }) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
    );

    return File(result!.path);
  }

  // update image in firestore
  static Future<String> updateImage({
    required File file,
    required bool isUser,
    required String id,
    required String reference,
  }) async {
    final imageURL = await uploadFileAndGetUrl(
      file: file,
      reference: reference,
    );
    if (isUser) {
      await FirebaseFirestore.instance
          .collection(Constants.usersCollection)
          .doc(id)
          .update({Constants.imageUrl: imageURL});
    } else {
      await FirebaseFirestore.instance
          .collection(Constants.organizationCollection)
          .doc(id)
          .update({Constants.imageUrl: imageURL});
    }

    return imageURL;
  }
}
