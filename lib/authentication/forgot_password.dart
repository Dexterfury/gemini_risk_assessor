import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Forgot Password',
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Enter your email address and click on the button below",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    bool isValidEmail = validateEmail(value.toString());
                    if (value!.isEmpty) {
                      return "Please enter your email";
                    } else if (!isValidEmail) {
                      return "Invalid email";
                    } else if (isValidEmail) {
                      return null;
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                SizedBox(
                  height: 50,
                  child: MainAppButton(
                    label: 'Send reset password link',
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        AuthenticationProvider.sendPasswordResetEmail(
                            context: context,
                            email: _emailController.text,
                            onSuccess: () {
                              showSnackBar(
                                context: context,
                                message:
                                    "Reset password link has been sent to ${_emailController.text}",
                              );
                            },
                            onError: (error) {
                              showSnackBar(
                                context: context,
                                message: error,
                              );
                            });
                      } else {
                        showSnackBar(
                            context: context, message: 'Form not valid');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
