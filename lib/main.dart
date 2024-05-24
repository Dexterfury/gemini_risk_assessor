import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/create_assessment_screen.dart';
import 'package:gemini_risk_assessor/screens/home_screen.dart';
import 'package:gemini_risk_assessor/themes/my_thesmes.dart';
import 'package:gemini_risk_assessor/widgets/risk_assessments_list.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

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
      home: const CreateAssessmentScreen(),
    );
  }
}
