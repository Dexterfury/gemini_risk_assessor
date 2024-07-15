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
          log("Downloaded file is empty");
          await setDownloadStatus(path.basename(filePath), false);
          return null;
        }
      } else {
        log("Failed to download file: ${response.statusCode}");
        await setDownloadStatus(path.basename(filePath), false);
        return null;
      }
    } catch (e) {
      log("Error downloading file: $e");
      await setDownloadStatus(path.basename(filePath), false);
      return null;
    }
  }

  static Future<void> openPDF(String filePath, String filename) async {
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      // Handle remote URL
      final localFilePath = await getLocalFilePath(filename);

      if (await isFileDownloaded(localFilePath) &&
          await getDownloadStatus(filename)) {
        await OpenFile.open(localFilePath);
      } else {
        final downloadedFile = await downloadFile(filePath, localFilePath);
        if (downloadedFile != null) {
          await OpenFile.open(downloadedFile.path);
        } else {
          log("Failed to download the file");
          log('url: $filePath');
          // Handle download failure (e.g., show an error message to the user)
        }
      }
    } else {
      // Handle local file path
      if (await File(filePath).exists()) {
        await OpenFile.open(filePath);
      } else {
        log("Local file not found: $filePath");
        // Handle file not found error
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
