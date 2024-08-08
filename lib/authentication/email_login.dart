import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/authentication/firebase_auth_error_handler.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/have_account_widget.dart';
import 'package:provider/provider.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<EmailLogin> {
  late String _email;
  late String _password;
  bool _obscureText = true;
  bool _sendEmailVerification = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // signIn user
  void signInUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    if (formKey.currentState!.validate()) {
      // save the form
      formKey.currentState!.save();

      try {
        final userCredential =
            await authProvider.signInUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        if (userCredential != null) {
          // 1. reload firebase user
          await authProvider.reloadUser();

          // 2. check email verification status
          final isVerified = await authProvider.isEmailVerified();

          if (isVerified) {
            // 1. check if this user exist in firestore
            bool userExist = await authProvider.checkUserExistsInFirestore(
                uid: userCredential.user!.uid);

            if (userExist) {
              await AnalyticsHelper.logLogin(
                SignInType.email.name,
              );
              // 2. get user data from firestore
              await authProvider.getUserDataFromFireStore();

              // 3. save user data to shared preferenced - local storage
              await authProvider.saveUserDataToSharedPreferences();

              // 4. reset the form
              formKey.currentState!.reset();

              // 5. remove loading
              authProvider.setLoading(false);

              // 5. navigate to home screen
              navigate(isSignedIn: true);
            } else {
              // navigate to user information
              navigate(isSignedIn: false);
            }
          } else {
            Future.delayed(const Duration(milliseconds: 200), () {
              showSnackBar(
                  context: context,
                  message: 'Please verify your email address');
            });
            setState(() {
              _sendEmailVerification = true;
            });
          }
        }
      } on FirebaseAuthException catch (e) {
        Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
          FirebaseAuthErrorHandler.showErrorSnackBar(context, e);
        });
      } catch (e) {
        Future.delayed(const Duration(milliseconds: 200), () {
          showSnackBar(
              context: context, message: 'An unexpected error occurred: $e');
        });
      } finally {
        authProvider.setLoading(false);
      }
    } else {
      showSnackBar(context: context, message: 'Please fill in all fields');
    }
  }

  navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      navigationController(
        context: context,
        route: Constants.screensControllerRoute,
      );
    } else {
      // navigate to user information screen
      navigationController(
        context: context,
        route: Constants.userInformationRoute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: const MyAppBar(leading: BackButton(), title: 'Sign In'),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 15,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset(
                      AssetsManager.appLogo,
                    )
                    //Lottie.asset(AssetsManager.clipboardAnimation),
                    ),
                const Text(
                  'Gemini Risk Assessor',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                    height: 50,
                    child: _sendEmailVerification
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: () async {
                                  try {
                                    await authProvider
                                        .sendEmailVerification()
                                        .whenComplete(() {
                                      showSnackBar(
                                        context: context,
                                        message:
                                            'A verification email has been sent to ${authProvider.getUserEmail()}',
                                      );
                                    });
                                  } catch (e) {
                                    Future.delayed(
                                            const Duration(milliseconds: 200))
                                        .whenComplete(() {
                                      showSnackBar(
                                        context: context,
                                        message: e.toString(),
                                      );
                                    });
                                  }
                                  Future.delayed(const Duration(seconds: 2))
                                      .whenComplete(() {
                                    setState(() {
                                      _sendEmailVerification = false;
                                    });
                                  });
                                },
                                child: const Text(
                                  'Resen Email Verification',
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          )
                        : const SizedBox.shrink()),
                TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your email',
                      hintText: 'Enter your email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!validateEmail(value)) {
                      return 'Please enter a valid email';
                    } else if (validateEmail(value)) {
                      return null;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _email = value.trim();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Enter your password',
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 8) {
                      return 'Password must be atleast 8 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _password = value;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // forgot password methodd here
                      Navigator.pushNamed(
                        context,
                        Constants.forgotPasswordRoute,
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: MainAppButton(
                          label: ' SIGN IN ',
                          onTap: signInUser,
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 40,
                ),
                HaveAccountWidget(
                  label: 'Don\'t have an account?',
                  labelAction: 'Sign Up',
                  onPressed: () {
                    // navigate to sign up screen
                    Navigator.pushNamed(context, Constants.emailSignUpRoute);
                  },
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
