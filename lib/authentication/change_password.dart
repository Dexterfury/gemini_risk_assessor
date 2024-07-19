import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/service/user_service.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Change Password',
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Fill in the form below to change your password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Old Password',
                          hintText: 'Enter old password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'New Password',
                          hintText: 'Enter your new password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Repeat Password',
                          hintText: 'Re-Enter your new password',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FlutterPwValidator(
                          controller: _newPasswordController,
                          minLength: 8,
                          uppercaseCharCount: 1,
                          lowercaseCharCount: 2,
                          numericCharCount: 2,
                          specialCharCount: 1,
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          onSuccess: () {},
                          onFail: () {}),
                      const SizedBox(height: 10),
                      const Spacer(),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MainAppButton(
                          label: 'Save Changes',
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await UserService.changePassword(
                                context,
                                _oldPasswordController.text,
                                _newPasswordController.text,
                              );
                              print('Password changed successfully');
                              // clear the form
                              _oldPasswordController.clear();
                              _newPasswordController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 56.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
