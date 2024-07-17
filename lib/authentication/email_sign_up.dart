import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/authentication/firebase_auth_error_handler.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/have_account_widget.dart';
import 'package:provider/provider.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({super.key});

  @override
  State<EmailSignUp> createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  File? _finalFileImage;
  late String name;
  late String email;
  late String password;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // signUp user
  void signUpUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    if (formKey.currentState!.validate()) {
      // save the form
      formKey.currentState!.save();

      try {
        final userCredential =
            await authProvider.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential != null) {
          // send email verification
          await authProvider.sendEmailVerification();

          // user has been created - now we save the user to firestore
          log('user created: ${userCredential.user!.uid}');

          UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            name: name,
            phone: '',
            email: email,
            imageUrl: '',
            token: '',
            aboutMe: 'Hey there, I\'m using Gemini Risk Assessor',
            createdAt: '',
          );

          // update data in firebase auth
          // update the display name in firebase auth
          await FirebaseAuth.instance.currentUser!.updateDisplayName(name);

          authProvider.saveUserDataToFireStore(
            userModel: userModel,
            fileImage: _finalFileImage,
            onSuccess: () async {
              formKey.currentState!.reset();
              // sign out the user and navigate to the login screen
              // so that he may now sign In
              showSnackBar(
                context: context,
                message:
                    'Sign Up successful, Please verify your email and sign In',
              );

              await authProvider.signOut().whenComplete(() {
                Navigator.pop(context);
              });
            },
            onFail: (error) {
              showSnackBar(context: context, message: error.toString());
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
          FirebaseAuthErrorHandler.showErrorSnackBar(context, e);
        });
      } catch (e) {
        log('error signUP: ${e.toString()}');
        Future.delayed(const Duration(milliseconds: 200), () {
          showSnackBar(
              context: context, message: 'An unexpected error occurred: $e');
        });
      } finally {
        authProvider.setLoading(false);
      }
    } else {
      showSnackBar(context: context, message: 'Please fill all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Sign Up',
      ),
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
                const SizedBox(
                  height: 20,
                ),
                DisplayUserImage(
                  radius: 60,
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
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 25,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    counterText: '',
                    labelText: 'Enter your name',
                    hintText: 'Enter your name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    } else if (value.length < 3) {
                      return 'Name must be atleast 3 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    name = value.trim();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your email',
                    hintText: 'Enter your email',
                  ),
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
                    email = value.trim();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Enter your password',
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: obscureText,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 8) {
                      return 'Password must be atleast 8 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    password = value;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: MainAppButton(
                          label: ' SIGN UP ',
                          onTap: signUpUser,
                        ),
                      ),
                const SizedBox(
                  height: 40,
                ),
                HaveAccountWidget(
                  label: 'Have an account?',
                  labelAction: 'Sign In',
                  onPressed: () {
                    Navigator.pop(context);
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
