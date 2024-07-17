import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Verification',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                const Text(
                  'Enter the 6-digit code sent the number',
                  textAlign: TextAlign.center,
                  style: textStyle18w500,
                ),

                const SizedBox(height: 10),

                // phone number text
                Text(phoneNumber,
                    textAlign: TextAlign.center, style: textStyle18w500),

                const SizedBox(height: 30),

                // pinPutField
                pinPutField(verificationId),

                const SizedBox(height: 30),

                // resend CodeField
                resendCodeField(authProvider, phoneNumber),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget resendCodeField(AuthProvider authProvider, String phoneNumber) {
    if (authProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (authProvider.isSuccessful) {
      return Container(
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.done,
          color: Colors.white,
          size: 30,
        ),
      );
    } else {
      return Column(
        children: [
          const Text(
            'Didn\'t receive the code?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextButton(
              onPressed: authProvider.secondsRemaining == 0
                  ? () {
                      // reset the code to send again
                      authProvider.resendCode(
                        context: context,
                        phone: phoneNumber,
                      );
                    }
                  : null,
              child: const Text('Resend Code', style: textStyle18w500)),
        ],
      );
    }
  }

  Widget pinPutField(String verificationId) {
    return SizedBox(
      height: 68,
      child: Pinput(
        length: 6,
        controller: controller,
        focusNode: focusNode,
        defaultPinTheme: defaultPinTheme,
        onCompleted: (pin) {
          setState(() {
            otpCode = pin;
          });
          // verify otp code
          verifyOTPCode(
            verificationId: verificationId,
            otpCode: otpCode!,
          );
        },
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 68,
          width: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.deepPurple,
            ),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          height: 68,
          width: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthProvider>();
    authProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: () async {
        // 1. check if user exists in firestore
        bool userExists = await authProvider.checkUserExistsInFirestore();

        if (userExists) {
          // 2. if user exists,

          // * get user information from firestore
          await authProvider.getUserDataFromFireStore();

          // * save user information to provider / shared preferences
          await authProvider.saveUserDataToSharedPreferences().whenComplete(() {
            // * navigate to home screen
            navigationController(
              context: context,
              route: Constants.screensControllerRoute,
            );
          });
        } else {
          // 3. if user doesn't exist, navigate to user information screen
          await Future.delayed(const Duration(milliseconds: 200))
              .whenComplete(() {
            navigationController(
              context: context,
              route: Constants.userInformationRoute,
            );
          });
        }
      },
    );
  }
}
