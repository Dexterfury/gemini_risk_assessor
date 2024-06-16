import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return Scaffold(
      appBar: MyAppBar(
        title: 'User Information',
        leading: backIcon(),
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
              onPressed: () {},
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                labelText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            MainAppButton(
              widget: const Icon(Icons.login),
              label: 'Continue',
              onTap: () {
                authProvider.isLoading
                    ? null
                    : () {
                        if (_nameController.text.isEmpty ||
                            _nameController.text.length < 3) {
                          showSnackBar(
                              context: context,
                              message: 'Please enter your name');
                          return;
                        }
                        // save user data to firestore
                        saveUserDataToFireStore();
                      };
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
      onSuccess: () async {
        // save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();

        navigateToHomeScreen();
      },
      onFail: () async {
        showSnackBar(context: context, message: 'Failed to save user data');
      },
    );
  }

  void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeRoute,
      (route) => false,
    );
  }
}
