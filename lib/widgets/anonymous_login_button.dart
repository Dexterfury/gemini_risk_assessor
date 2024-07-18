import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/authentication/firebase_auth_error_handler.dart';
import 'package:gemini_risk_assessor/buttons/auth_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';

// class AnonymousLoginButton extends StatelessWidget {
//   const AnonymousLoginButton({
//     super.key,
//     required this.authProvider,
//     required this.phoneNumberController,
//   });

//   final AuthenticationProvider authProvider;
//   final TextEditingController phoneNumberController;

//   @override
//   Widget build(BuildContext context) {
//     bool isAnonymous = authProvider.isUserAnonymous();
//     return phoneNumberController.text.isNotEmpty
//         ? const SizedBox()
//         : AuthButton(
//             icon: FontAwesomeIcons.solidCircleUser,
//             label: 'Sign in Anonymous',
//             onTap: () {
//               if (!authProvider.isLoading) {
//                 if (isAnonymous) {
//                   // set loading back to false
//                   authProvider.setLoading(false);
//                   // * navigate to home screen
//                   navigationController(
//                     context: context,
//                     route: Constants.screensControllerRoute,
//                   );
//                   return;
//                 }

//                 try {
//                   authProvider.signInAnonymously(
//                     onSuccess: () async {
//                       bool userExists =
//                           await authProvider.checkUserExistsInFirestore();
//                       if (userExists) {
//                         // 2. if user exists,

//                         // * get user information from firestore
//                         await authProvider.getUserDataFromFireStore();

//                         // * save user information to provider / shared preferences
//                         await authProvider
//                             .saveUserDataToSharedPreferences()
//                             .whenComplete(() {
//                           // * navigate to home screen
//                           navigationController(
//                             context: context,
//                             route: Constants.screensControllerRoute,
//                           );
//                         });
//                       } else {
//                         // we generate a random name here
//                         final name =
//                             "User${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}";
//                         UserModel userModel = UserModel(
//                           uid: authProvider.uid!,
//                           name: name,
//                           phone: '',
//                           email: '',
//                           imageUrl: '',
//                           token: '',
//                           aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
//                           isAnonymous: true,
//                           createdAt: '',
//                         );
//                         authProvider.saveUserDataToFireStore(
//                           fileImage: null,
//                           userModel: userModel,
//                           onSuccess: () async {
//                             // save user data to shared preferences
//                             await authProvider
//                                 .saveUserDataToSharedPreferences()
//                                 .whenComplete(() {
//                               // navigate to home screen
//                               navigationController(
//                                 context: context,
//                                 route: Constants.screensControllerRoute,
//                               );
//                             });
//                           },
//                         );
//                       }
//                     },
//                   );
//                 } on FirebaseAuthException catch (e) {
//                   Future.delayed(const Duration(milliseconds: 200))
//                       .whenComplete(() {
//                     FirebaseAuthErrorHandler.showErrorSnackBar(context, e);
//                   });
//                 } catch (e) {
//                   Future.delayed(const Duration(milliseconds: 200), () {
//                     showSnackBar(
//                         context: context,
//                         message: 'An unexpected error occurred: $e');
//                   });
//                 } finally {
//                   authProvider.setLoading(false);
//                 }
//               }
//             },
//           );
//   }
// }
