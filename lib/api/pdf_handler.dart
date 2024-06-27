import 'dart:developer';
import 'dart:io';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PDFHandler {
  static Future<String> getLocalFilePath(String filename) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    return path.join(appDocDir.path, filename);
  }

  static Future<bool> isFileDownloaded(String filePath) async {
    final file = File(filePath);
    return await file.exists() && await file.length() > 0;
  }

  static Future<void> setDownloadStatus(String filename, bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pdf_downloaded_$filename', status);
  }

  static Future<bool> getDownloadStatus(String filename) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pdf_downloaded_$filename') ?? false;
  }

  static Future<File?> downloadFile(String url, String filePath) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (await file.length() > 0) {
          await setDownloadStatus(path.basename(filePath), true);
          return file;
        } else {
          print("Downloaded file is empty");
          await setDownloadStatus(path.basename(filePath), false);
          return null;
        }
      } else {
        print("Failed to download file: ${response.statusCode}");
        await setDownloadStatus(path.basename(filePath), false);
        return null;
      }
    } catch (e) {
      print("Error downloading file: $e");
      await setDownloadStatus(path.basename(filePath), false);
      return null;
    }
  }

  static Future<void> openPDF(String url, String filename) async {
    final filePath = await getLocalFilePath(filename);

    if (await isFileDownloaded(filePath) && await getDownloadStatus(filename)) {
      print("Opening existing file: $filePath");
      await OpenFile.open(filePath);
    } else {
      print("Downloading file from: $url");
      final downloadedFile = await downloadFile(url, filePath);
      if (downloadedFile != null) {
        print(
            "File downloaded successfully. Size: ${await downloadedFile.length()} bytes");
        await OpenFile.open(downloadedFile.path);
      } else {
        print("Failed to download the file");
        // Handle download failure (e.g., show an error message to the user)
      }
    }
  }

  // Function to delete the file
  static Future<void> deleteFile(String filename) async {
    final filePath = await getLocalFilePath(filename);
    final file = File(filePath);
    await file.delete();
  }
}
