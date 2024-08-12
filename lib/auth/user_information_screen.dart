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
import 'package:gemini_risk_assessor/utilities/responsive_layout_helper.dart';
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
      body: ResponsiveLayoutHelper.responsiveBuilder(
        context: context,
        mobile: _buildMobileLayout(authProvider),
        tablet: _buildTabletLayout(authProvider),
        desktop: _buildDesktopLayout(authProvider),
      ),
    );
  }

  Widget _buildMobileLayout(AuthenticationProvider authProvider) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: ResponsiveLayoutHelper.responsivePadding(
            context,
            mobile: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            tablet: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            desktop: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserImage(),
              const SizedBox(height: 30),
              _buildNameInputField(authProvider),
              const SizedBox(height: 40),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(AuthenticationProvider authProvider) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserImage(radius: 75),
              const SizedBox(height: 40),
              SizedBox(
                width: ResponsiveLayoutHelper.widthPercent(context, 0.6),
                child: _buildNameInputField(authProvider),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: ResponsiveLayoutHelper.widthPercent(context, 0.4),
                child: _buildContinueButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(AuthenticationProvider authProvider) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserImage(radius: 100),
              const SizedBox(height: 50),
              SizedBox(
                width: ResponsiveLayoutHelper.widthPercent(context, 0.4),
                child: _buildNameInputField(authProvider),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: ResponsiveLayoutHelper.widthPercent(context, 0.3),
                child: _buildContinueButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserImage({double radius = 50}) {
    return DisplayUserImage(
      radius: radius,
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
    );
  }

  Widget _buildNameInputField(AuthenticationProvider authProvider) {
    return InputField(
      labelText: Constants.enterYourName,
      hintText: Constants.enterYourName,
      controller: _nameController,
      authProvider: authProvider,
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 50,
      child: MainAppButton(
        label: 'Continue',
        onTap: () {
          if (_nameController.text.isEmpty || _nameController.text.length < 3) {
            showSnackBar(context: context, message: 'Please enter your name');
            return;
          }
          saveUserDataToFireStore();
        },
      ),
    );
  }

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
      safetyFileUrl: '',
      safetyFileContent: '',
      useSafetyFile: false,
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

// class UserInformationScreen extends StatefulWidget {
//   const UserInformationScreen({
//     super.key,
//     this.uid = '',
//   });

//   final String uid;

//   @override
//   State<UserInformationScreen> createState() => _UserInformationScreenState();
// }

// class _UserInformationScreenState extends State<UserInformationScreen> {
//   final TextEditingController _nameController = TextEditingController();

//   File? _finalFileImage;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthenticationProvider>();
//     return Scaffold(
//       appBar: const MyAppBar(
//         title: 'User Information',
//         leading: BackButton(),
//       ),
//       body: Center(
//           child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 20,
//           vertical: 20.0,
//         ),
//         child: Column(
//           children: [
//             DisplayUserImage(
//               radius: 50,
//               isViewOnly: false,
//               fileImage: _finalFileImage,
//               onPressed: () async {
//                 final file = await ImagePickerHandler.showImagePickerDialog(
//                   context: context,
//                 );
//                 if (file != null) {
//                   setState(() {
//                     _finalFileImage = file;
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 30),

//             // name input field
//             InputField(
//               labelText: Constants.enterYourName,
//               hintText: Constants.enterYourName,
//               controller: _nameController,
//               authProvider: authProvider,
//             ),

//             const SizedBox(height: 40),

//             SizedBox(
//               height: 50,
//               width: MediaQuery.of(context).size.width,
//               child: MainAppButton(
//                 label: 'Continue',
//                 onTap: () {
//                   if (_nameController.text.isEmpty ||
//                       _nameController.text.length < 3) {
//                     showSnackBar(
//                         context: context, message: 'Please enter your name');
//                     return;
//                   }
//                   // save user data to firestore
//                   saveUserDataToFireStore();
//                 },
//               ),
//             ),
//           ],
//         ),
//       )),
//     );
//   }

//   // save user data to firestore
//   void saveUserDataToFireStore() async {
//     final authProvider = context.read<AuthenticationProvider>();
//     final uid =
//         widget.uid.isNotEmpty ? widget.uid : authProvider.userModel!.uid;

//     MyDialogs.showMyAnimatedDialog(
//       context: context,
//       title: 'Saving User Information',
//       loadingIndicator:
//           const SizedBox(height: 100, width: 100, child: LoadingPPEIcons()),
//     );

//     UserModel userModel = UserModel(
//       uid: uid,
//       name: _nameController.text.trim(),
//       phone: authProvider.phoneNumber ?? '',
//       email: '',
//       imageUrl: '',
//       token: '',
//       aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
//       rating: 0,
//       safetyPoints: 0,
//       safetyFileUrl: '',
//       safetyFileContent: '',
//       useSafetyFile: false,
//       isAnonymous: false,
//       createdAt: '',
//     );

//     try {
//       authProvider.setLoading(true);
//       authProvider.saveUserDataToFireStore(
//         userModel: userModel,
//         fileImage: _finalFileImage,
//         onSuccess: () async {
//           Navigator.pop(context);
//           // save user data to shared preferences
//           await authProvider.saveUserDataToSharedPreferences().whenComplete(() {
//             navigationController(
//               context: context,
//               route: Constants.screensControllerRoute,
//             );
//           });
//         },
//       );
//     } on FirebaseAuthException catch (e) {
//       Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
//         FirebaseAuthErrorHandler.showErrorSnackBar(context, e);
//       });
//     } catch (e) {
//       Future.delayed(const Duration(milliseconds: 200), () {
//         showSnackBar(
//             context: context, message: 'An unexpected error occurred: $e');
//       });
//     } finally {}
//   }
// }
