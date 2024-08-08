import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/auth/firebase_auth_error_handler.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({
    super.key,
    this.uid = '',
  });

  final String uid;

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
    final authProvider = context.watch<AuthenticationProvider>();
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

            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: MainAppButton(
                label: 'Continue',
                onTap: () {
                  if (_nameController.text.isEmpty ||
                      _nameController.text.length < 3) {
                    showSnackBar(
                        context: context, message: 'Please enter your name');
                    return;
                  }
                  // save user data to firestore
                  saveUserDataToFireStore();
                },
              ),
            ),
          ],
        ),
      )),
    );
  }

  // save user data to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();
    final uid =
        widget.uid.isNotEmpty ? widget.uid : authProvider.userModel!.uid;

    MyDialogs.showMyAnimatedDialog(
      context: context,
      title: 'Saving User Information',
      loadingIndicator:
          const SizedBox(height: 100, width: 100, child: LoadingPPEIcons()),
    );

    UserModel userModel = UserModel(
      uid: uid,
      name: _nameController.text.trim(),
      phone: authProvider.phoneNumber ?? '',
      email: '',
      imageUrl: '',
      token: '',
      aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
      rating: 0,
      safetyPoints: 0,
      isAnonymous: false,
      createdAt: '',
    );

    try {
      authProvider.setLoading(true);
      authProvider.saveUserDataToFireStore(
        userModel: userModel,
        fileImage: _finalFileImage,
        onSuccess: () async {
          Navigator.pop(context);
          // save user data to shared preferences
          await authProvider.saveUserDataToSharedPreferences().whenComplete(() {
            navigationController(
              context: context,
              route: Constants.screensControllerRoute,
            );
          });
        },
      );
    } on FirebaseAuthException catch (e) {
      Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
        FirebaseAuthErrorHandler.showErrorSnackBar(context, e);
      });
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 200), () {
        showSnackBar(
            context: context, message: 'An unexpected error occurred: $e');
      });
    } finally {}
  }
}
