import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();

  File? _finalFileImage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: const MyAppBar(
        title: 'User Information',
        leading: BackButton(),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            DisplayUserImage(
              radius: 50,
              isViewOnly: false,
              fileImage: _finalFileImage,
              onPressed: () async {
                final file = await ImagePickerHandler.showImagePickerDialog(
                  context: context,
                );
                if (file != null) {
                  setState(() {
                    _finalFileImage = file;
                  });
                }
              },
            ),
            const SizedBox(height: 30),

            // name input field
            InputField(
              labelText: Constants.enterYourName,
              hintText: Constants.enterYourName,
              controller: _nameController,
              authProvider: authProvider,
            ),

            const SizedBox(height: 40),

            authProvider.isLoading
                ? const CircularProgressIndicator()
                : MainAppButton(
                    icon: Icons.login,
                    label: 'Continue',
                    onTap: () {
                      if (_nameController.text.isEmpty ||
                          _nameController.text.length < 3) {
                        showSnackBar(
                            context: context,
                            message: 'Please enter your name');
                        return;
                      }
                      // save user data to firestore
                      saveUserDataToFireStore();
                    },
                  ),
          ],
        ),
      )),
    );
  }

  // save user data to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phone: authProvider.phoneNumber!,
      imageUrl: '',
      token: '',
      aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
      createdAt: '',
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      fileImage: _finalFileImage,
      onSuccess: () async {
        // save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences().whenComplete(() {
          navigationController(
            context: context,
            route: Constants.screensControllerRoute,
          );
        });
      },
      onFail: () async {
        showSnackBar(context: context, message: 'Failed to save user data');
      },
    );
  }
}
