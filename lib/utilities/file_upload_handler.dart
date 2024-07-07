import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gemini_risk_assessor/constants.dart';

class FileUploadHandler {
  // compress, upload and return file url
  static Future<String> uploadFileAndGetUrl({
    required File file,
    required String reference,
  }) async {
    File compressedFile = await compressAndGetFile(
      file: file,
      targetPath: '${file.path}.jpg',
    );

    String downloadUrl = await storeFileToStorage(
      file: compressedFile,
      reference: reference,
    );
    return downloadUrl;
  }

  // store file to storage and return file url
  static Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask =
        FirebaseStorage.instance.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  // compress file and get file.
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
          .collection(Constants.organisationCollection)
          .doc(id)
          .update({Constants.imageUrl: imageURL});
    }

    return imageURL;
  }
}
