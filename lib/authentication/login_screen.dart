import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/widgets/anonymous_login_button.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 40.0,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(AssetsManager.clipboardAnimation),
            ),
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
            AnonymousLoginButton(authProvider: authProvider),
          ],
        ),
      ),
    ));
  }

  TextFormField phoneField(
    AuthProvider authProvider,
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
          final phoneNumber = '+${selectedCountry.phoneCode}$value';
          // show loading Dialog
          // show my alert dialog for loading
          MyDialogs.showMyAnimatedDialog(
            context: context,
            title: 'Authenticating...',
            loadingIndicator: const SizedBox(
                height: 100, width: 100, child: LoadingPPEIcons()),
          );

          // sign in with phone number
          authProvider.signInWithPhoneNumber(
              phoneNumber: phoneNumber,
              context: context,
              onSuccess: () {
                // pop the loading dialog
                Navigator.pop(context);
              });
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
        // suffixIcon: authProvider.isLoading
        //     ? const Padding(
        //         padding: EdgeInsets.all(8.0),
        //         child: CircularProgressIndicator(),
        //       )
        //     : null,
        // //     : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
