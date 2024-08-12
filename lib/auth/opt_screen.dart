import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/responsive/responsive_layout_helper.dart';
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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Verification',
      ),
      body: SafeArea(
        child: ResponsiveLayoutHelper.responsiveBuilder(
          context: context,
          mobile: _buildMobileLayout(verificationId, phoneNumber, authProvider),
          tablet: _buildTabletLayout(verificationId, phoneNumber, authProvider),
          desktop:
              _buildDesktopLayout(verificationId, phoneNumber, authProvider),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(String verificationId, String phoneNumber,
      AuthenticationProvider authProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildInstructions(phoneNumber),
            const SizedBox(height: 30),
            pinPutField(verificationId),
            const SizedBox(height: 30),
            resendCodeField(authProvider, phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(String verificationId, String phoneNumber,
      AuthenticationProvider authProvider) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: ResponsiveLayoutHelper.widthPercent(context, 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 60),
              _buildInstructions(phoneNumber),
              const SizedBox(height: 40),
              pinPutField(verificationId),
              const SizedBox(height: 40),
              resendCodeField(authProvider, phoneNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(String verificationId, String phoneNumber,
      AuthenticationProvider authProvider) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: ResponsiveLayoutHelper.widthPercent(context, 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 80),
              _buildInstructions(phoneNumber),
              const SizedBox(height: 50),
              pinPutField(verificationId),
              const SizedBox(height: 50),
              resendCodeField(authProvider, phoneNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions(String phoneNumber) {
    return Column(
      children: [
        Text(
          'Enter the 6-digit code sent to the number',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveLayoutHelper.responsiveFontSize(
              context,
              mobile: AppTheme.textStyle18w500.fontSize!,
              tablet: 20,
              desktop: 22,
            ),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          phoneNumber,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveLayoutHelper.responsiveFontSize(
              context,
              mobile: AppTheme.textStyle18w500.fontSize!,
              tablet: 20,
              desktop: 22,
            ),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget resendCodeField(
      AuthenticationProvider authProvider, String phoneNumber) {
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
          Text(
            'Didn\'t receive the code?',
            style: TextStyle(
              fontSize: ResponsiveLayoutHelper.responsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: authProvider.secondsRemaining == 0
                ? () {
                    authProvider.resendCode(
                      context: context,
                      phone: phoneNumber,
                    );
                  }
                : null,
            child: Text(
              'Resend Code',
              style: TextStyle(
                fontSize: ResponsiveLayoutHelper.responsiveFontSize(
                  context,
                  mobile: AppTheme.textStyle18w500.fontSize!,
                  tablet: 20,
                  desktop: 22,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget pinPutField(String verificationId) {
    return SizedBox(
      height: ResponsiveLayoutHelper.responsiveFontSize(
        context,
        mobile: 68,
        tablet: 80,
        desktop: 90,
      ),
      child: Pinput(
        length: 6,
        controller: controller,
        focusNode: focusNode,
        defaultPinTheme: AppTheme.getDefaultPinTheme(context),
        onCompleted: (pin) {
          setState(() {
            otpCode = pin;
          });
          verifyOTPCode(
            verificationId: verificationId,
            otpCode: otpCode!,
          );
        },
        focusedPinTheme: AppTheme.getFocusPinTheme(context),
        errorPinTheme: AppTheme.getErrorPinTheme(context),
      ),
    );
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: (uid) async {
        // 1. check if user exists in firestore
        bool? userExists =
            await authProvider.checkUserExistsInFirestore(uid: uid);

        if (userExists == true) {
          // 2. if user exists
          await authProvider.getUserDataFromFireStore();
          await authProvider.saveUserDataToSharedPreferences();
          navigationController(
            context: context,
            route: Constants.screensControllerRoute,
          );
        } else if (userExists == false) {
          // 3. if user doesn't exist
          await Future.delayed(const Duration(milliseconds: 200));
          navigationController(
            context: context,
            route: Constants.userInformationRoute,
          );
        } else {
          // 4. there was an error
          showSnackBar(
            context: context,
            message:
                'Error checking user data, Please check connection and try again',
          );
        }
      },
    );
  }
}
