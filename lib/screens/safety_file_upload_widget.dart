import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/settings_switch_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SafetyFileUploadWidget extends StatelessWidget {
  final String userID;

  const SafetyFileUploadWidget({Key? key, required this.userID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: MyAppBar(leading: BackButton(), title: 'Safety File Setttings'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SettingsSwitchListTile(
                title: 'Use My Safety File',
                subtitle:
                    'Apply custom safety guidelines to AI-generated content',
                icon: FontAwesomeIcons.shieldHalved,
                containerColor: Colors.orange,
                value: authProvider.userModel!.useSafetyFile,
                onChanged: (value) {
                  _handleUseSafetyFile(
                    context,
                    authProvider,
                    value,
                  );
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  _showFilePicker(context, authProvider);
                },
                child: Text('Upload Safety File (PDF only)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showFilePicker(BuildContext context, AuthenticationProvider authProvider,
    {bool fromSwitch = false}) async {
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
        loadingIndicator:
            const SizedBox(height: 100, width: 100, child: LoadingPPEIcons()),
      );
      final (String safetyFileUrl, String safetyFileContent) =
          await FileUploadHandler.uploadSafetyFile(
        context: context,
        file: file,
        collectionID: authProvider.userModel!.uid,
      );
      Navigator.pop(context);
      if (safetyFileUrl.isNotEmpty) {
        await FirebaseMethods.saveSafetyFile(
          collectionID: authProvider.userModel!.uid,
          isUser: true,
          safetyFileUrl: safetyFileUrl,
          safetyFileContent: safetyFileContent,
        ).whenComplete(() {
          showSnackBar(
              context: context, message: 'Safety file uploaded successfully');
          if (fromSwitch) {
            authProvider.updateUserSafetyFile(true);
            FirebaseMethods.ToggleUseSafetyFileInFirestore(
              collectionID: authProvider.userModel!.uid,
              isUser: true,
              value: true,
            );
          }
        });
      } else {
        if (fromSwitch) {
          authProvider.updateUserSafetyFile(false);
          FirebaseMethods.ToggleUseSafetyFileInFirestore(
            collectionID: authProvider.userModel!.uid,
            isUser: true,
            value: false,
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      showSnackBar(
          context: context, message: 'Error uploading file: ${e.toString()}');
    }
  }
}

void _handleUseSafetyFile(
  BuildContext context,
  AuthenticationProvider authProvider,
  bool value,
) {
  if (value) {
    if (authProvider.userModel!.safetyFileContent.length < 1000) {
      // open file picker
      _showFilePicker(context, authProvider, fromSwitch: value);
    } else {
      authProvider.updateUserSafetyFile(true);
      FirebaseMethods.ToggleUseSafetyFileInFirestore(
        collectionID: authProvider.userModel!.uid,
        isUser: true,
        value: true,
      );
    }
  } else {
    authProvider.updateUserSafetyFile(false);
    FirebaseMethods.ToggleUseSafetyFileInFirestore(
      collectionID: authProvider.userModel!.uid,
      isUser: true,
      value: false,
    );
  }
}
