import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:lottie/lottie.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    //checkAthentication();
    super.initState();
  }

  // void checkAthentication() async {
  //   final authProvider = context.read<AuthProvider>();
  //   bool isAuthenticated = await authProvider.checkAuthenticationState();

  //   navigate(isAuthenticated: isAuthenticated);
  // }

  // navigate({required bool isAuthenticated}) {
  //   if (isAuthenticated) {
  //     Navigator.pushReplacementNamed(context, Constants.homeScreen);
  //   } else {
  //     Navigator.pushReplacementNamed(context, Constants.loginScreen);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          width: 200,
          child: Lottie.asset(AssetsManager.clipboardAnimation),
        ),
      ),
    );
  }
}
