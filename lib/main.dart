import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/authentication/landing_screen.dart';
import 'package:gemini_risk_assessor/authentication/login_screen.dart';
import 'package:gemini_risk_assessor/authentication/opt_screen.dart';
import 'package:gemini_risk_assessor/authentication/user_information_screen.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_options.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/home_screen.dart';
import 'package:gemini_risk_assessor/screens/screens_controller.dart';
import 'package:gemini_risk_assessor/themes/my_thesmes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => AssessmentProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: Constants.riskAssessments,
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: Constants.landingRoute,
        routes: {
          Constants.landingRoute: (context) => const LandingScreen(),
          Constants.logingRoute: (context) => const LoginScreen(),
          Constants.homeRoute: (context) => const HomeScreen(),
          Constants.screensControllerRoute: (context) =>
              const ScreensController(),
          Constants.optRoute: (context) => const OTPScreen(),
          Constants.userInformationRoute: (context) =>
              const UserInformationScreen(),
        });
  }
}
