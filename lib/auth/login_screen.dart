import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/auth/firebase_auth_error_handler.dart';
import 'package:gemini_risk_assessor/auth/social_auth_buttons.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isValid = false;

  Country selectedCountry = Country(
    phoneCode: '1',
    countryCode: 'USA',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'USA',
    example: 'USA',
    displayName: 'USA',
    displayNameNoCountryCode: 'US',
    e164Key: '',
  );

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> handleClickedButton(SignInType authType) async {
    final authProvider = context.read<AuthenticationProvider>();
    try {
      UserCredential? userCredential;
      switch (authType) {
        case SignInType.email:
          Navigator.pushNamed(context, Constants.emailSignInRoute);
          return;
        case SignInType.google:
        case SignInType.apple:
        case SignInType.anonymous:
          userCredential = await authProvider.socialLogin(
            context: context,
            signInType: authType,
          );
          break;
        default:
          throw Exception('Invalid sign in type');
      }

      if (userCredential != null) {
        // show my alert dialog for loading
        MyDialogs.showMyAnimatedDialog(
          context: context,
          title: 'Authenticating...',
          loadingIndicator: const SizedBox(
            height: 100,
            width: 100,
            child: LoadingPPEIcons(),
          ),
        );
        // Handle successful authentication
        bool? userExists = await authProvider.checkUserExistsInFirestore(
            uid: userCredential.user!.uid);
        bool wasAnonymous = authProvider.isUserAnonymous();

        if (userExists == true && !wasAnonymous) {
          await AnalyticsHelper.logLogin(
            authType.name,
          );
          await authProvider.getUserDataFromFireStore();
          await authProvider.saveUserDataToSharedPreferences();
        } else if (userExists == false) {
          await AnalyticsHelper.logSignUp(
            authType.name,
          );
          // Fetch the user again to ensure we have the updated information
          await userCredential.user?.reload();
          final updatedUser = FirebaseAuth.instance.currentUser;

          await authProvider.createAndSaveNewUser(
            updatedUser!,
            wasAnonymous,
          );
        } else {
          // 4. there was an error
          showSnackBar(
            context: context,
            message:
                'Error checking user data, Please check connection and try again',
          );
        }

        // pop the loading dialog
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
          // Navigate to the main screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            Constants.screensControllerRoute,
            (route) => false,
          );
        });
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
    }
  }

  void handlePhoneSignIn({
    required String phoneNumber,
    required AuthenticationProvider authProvider,
  }) async {
    Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
      // show loading Dialog
      // show my alert dialog for loading
      MyDialogs.showMyAnimatedDialog(
        context: context,
        title: 'Authenticating...',
        loadingIndicator:
            const SizedBox(height: 100, width: 100, child: LoadingPPEIcons()),
      );

      try {
        // sign in with phone number
        authProvider.signInWithPhoneNumber(
            phoneNumber: phoneNumber,
            context: context,
            onSuccess: () {
              // pop the loading dialog
              Navigator.pop(context);
            });
      } on FirebaseAuthException catch (e) {
        // pop the loading dialog
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
          FirebaseAuthErrorHandler.showErrorSnackBar(context, e);
        });
      } catch (e) {
        // pop the loading dialog
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200)).whenComplete(() {
          showSnackBar(
              context: context, message: 'An unexpected error occurred: $e');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final isLoading = authProvider.isLoading;
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 40.0,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(
                  AssetsManager.appLogo,
                )),
            const Text(
              'Gemini Risk Assessor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Add your phone number will send you a code to verify',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            phoneField(authProvider, context),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: MainAppButton(
                label: ' SIGN IN WITH PHONE ',
                onTap: () {
                  if (authProvider.isLoading) {
                    return;
                  }
                  if (_isValid) {
                    final phoneNumber =
                        '+${selectedCountry.phoneCode}${_phoneNumberController.text}';
                    handlePhoneSignIn(
                      phoneNumber: phoneNumber,
                      authProvider: authProvider,
                    );
                  } else {
                    showSnackBar(
                      context: context,
                      message: 'Please enter a valid phone number',
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Or continue with',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            isLoading
                ? const CircularProgressIndicator()
                : SocialAuthButtons(
                    onTap: handleClickedButton,
                  ),
          ],
        ),
      ),
    ));
  }

  TextFormField phoneField(
    AuthenticationProvider authProvider,
    BuildContext context,
  ) {
    return TextFormField(
      controller: _phoneNumberController,
      maxLength: 10,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        setState(() {
          _phoneNumberController.text = value;
        });
        if (_phoneNumberController.text.length > 9) {
          _isValid = true;
        } else {
          _isValid = false;
        }
      },
      decoration: InputDecoration(
        counterText: '',
        hintText: 'Phone Number',
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.fromLTRB(
            8.0,
            12.0,
            8.0,
            12.0,
          ),
          child: InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                countryListTheme:
                    const CountryListThemeData(bottomSheetHeight: 500),
                onSelect: (Country country) {
                  setState(() {
                    selectedCountry = country;
                  });
                },
              );
            },
            child: Text(
              '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        suffixIcon: _isValid
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  child: Icon(
                    FontAwesomeIcons.check,
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
