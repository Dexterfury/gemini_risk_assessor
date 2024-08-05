import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/authentication/user_information_screen.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  void checkAuthentication() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    AuthStatus authStatus = await authProvider.checkAuthenticationState(
      uid: _auth.currentUser?.uid,
    );
    navigate(authStatus: authStatus);
  }

  void navigate({required AuthStatus authStatus}) {
    switch (authStatus) {
      case AuthStatus.authenticated:
        Navigator.pushReplacementNamed(
            context, Constants.screensControllerRoute);
        break;
      case AuthStatus.authenticatedButNoData:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserInformationScreen(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
        );
        break;
      case AuthStatus.unauthenticated:
        Navigator.pushReplacementNamed(context, Constants.logingRoute);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   height: 200,
            //   width: 200,
            //   child: Lottie.asset(AssetsManager.clipboardAnimation),
            // ),
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
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
