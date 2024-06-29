import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';

class AnonymousLoginButton extends StatelessWidget {
  const AnonymousLoginButton({
    super.key,
    required this.authProvider,
  });

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = authProvider.isUserAnonymous();
    return authProvider.isLoading
        ? const SizedBox()
        : MainAppButton(
            icon: Icons.person,
            label: 'Continue as Guest',
            onTap: () async {
              if (!authProvider.isLoading) {
                if (isAnonymous) {
                  // set loading back to false
                  authProvider.setLoading(false);
                  // * navigate to home screen
                  navigationController(
                    context: context,
                    route: Constants.screensControllerRoute,
                  );
                  return;
                }

                authProvider.signInAnonymously(
                  onSuccess: () async {
                    bool userExists =
                        await authProvider.checkUserExistsInFirestore();
                    if (userExists) {
                      // 2. if user exists,

                      // * get user information from firestore
                      await authProvider.getUserDataFromFireStore();

                      // * save user information to provider / shared preferences
                      await authProvider
                          .saveUserDataToSharedPreferences()
                          .whenComplete(() {
                        // * navigate to home screen
                        navigationController(
                          context: context,
                          route: Constants.screensControllerRoute,
                        );
                      });
                    } else {
                      // we generate a random name here
                      final name =
                          "User${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}";
                      UserModel userModel = UserModel(
                        uid: authProvider.uid!,
                        name: name,
                        phone: '',
                        imageUrl: '',
                        token: '',
                        aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
                        createdAt: '',
                      );
                      authProvider.saveUserDataToFireStore(
                        fileImage: null,
                        userModel: userModel,
                        onSuccess: () async {
                          // save user data to shared preferences
                          await authProvider
                              .saveUserDataToSharedPreferences()
                              .whenComplete(() {
                            // navigate to home screen
                            navigationController(
                              context: context,
                              route: Constants.screensControllerRoute,
                            );
                          });
                        },
                        onFail: () async {
                          showSnackBar(
                              context: context,
                              message: 'Failed to save user data');
                        },
                      );
                    }
                  },
                  onFail: (error) {
                    showSnackBar(context: context, message: error);
                  },
                );
              }
            },
          );
  }
}
