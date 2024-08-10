import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SafetyFileUploadWidget extends StatelessWidget {
  final String userID;

  const SafetyFileUploadWidget({Key? key, required this.userID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    return Scaffold(
      appBar: MyAppBar(leading: BackButton(), title: 'Safety File Setttings'),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );

                if (result != null) {
                  final file = File(result.files.single.path!);
                  try {
                    MyDialogs.showMyAnimatedDialog(
                      context: context,
                      title: 'Uploading Safety File',
                      loadingIndicator: const SizedBox(
                          height: 100, width: 100, child: LoadingPPEIcons()),
                    );
                    final (String safetyFileUrl, String safetyFileContent) =
                        await FileUploadHandler.uploadSafetyFile(
                      context: context,
                      file: file,
                      collectionID: userID,
                    );
                    Navigator.pop(context);
                    if (safetyFileUrl.isNotEmpty) {
                      await FirebaseMethods.saveSafetyFile(
                        collectionID: userID,
                        isUser: true,
                        safetyFileUrl: safetyFileUrl,
                        safetyFileContent: safetyFileContent,
                      );
                      if (context.mounted)
                        showSnackBar(
                            context: context,
                            message: 'Safety file uploaded successfully');
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    showSnackBar(
                        context: context,
                        message: 'Error uploading file: ${e.toString()}');
                  }
                }
              },
              child: Text('Upload Safety File (PDF only)'),
            ),
            SwitchListTile(
              title: Text('Use My Safety File'),
              value: authProvider.useMySafetyFile,
              onChanged: (bool value) {
                authProvider.toggleUseSafetyFile(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
