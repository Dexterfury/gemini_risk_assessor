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
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/create_assessment_screen.dart';
import 'package:gemini_risk_assessor/screens/create_explainer_screen.dart';
import 'package:gemini_risk_assessor/screens/home_screen.dart';
import 'package:gemini_risk_assessor/screens/profile_screen.dart';
import 'package:gemini_risk_assessor/screens/screens_controller.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider()),
      ChangeNotifierProvider(create: (context) => AssessmentProvider()),
      ChangeNotifierProvider(create: (context) => ToolsProvider()),
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
          Constants.createAssessmentRoute: (context) =>
              const CreateAssessmentScreen(),
          Constants.createToolRoute: (context) => const CreateExplainerScreen(),
          Constants.profileRoute: (context) => const ProfileScreen(),
        });
  }
}
