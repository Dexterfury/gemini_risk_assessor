import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/authentication/email_login.dart';
import 'package:gemini_risk_assessor/authentication/email_sign_up.dart';
import 'package:gemini_risk_assessor/authentication/forgot_password.dart';
import 'package:gemini_risk_assessor/authentication/landing_screen.dart';
import 'package:gemini_risk_assessor/authentication/login_screen.dart';
import 'package:gemini_risk_assessor/authentication/opt_screen.dart';
import 'package:gemini_risk_assessor/authentication/user_information_screen.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/firebase_options.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/chat_provider.dart';
import 'package:gemini_risk_assessor/discussions/discussion_chat_provider.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/providers/theme_provider.dart';
import 'package:gemini_risk_assessor/tools/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/create_assessment_screen.dart';
import 'package:gemini_risk_assessor/tools/create_explainer_screen.dart';
import 'package:gemini_risk_assessor/groups/create_group_screen.dart';
import 'package:gemini_risk_assessor/screens/home_screen.dart';
import 'package:gemini_risk_assessor/screens/screens_controller.dart';
import 'package:gemini_risk_assessor/firebase_methods/error_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandler.recordError(details.exception, details.stack,
        reason: details.context.toString());
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.recordError(error, stack, reason: 'PlatformDispatcher error');
    return true;
  };
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
      ChangeNotifierProvider(create: (context) => AssessmentProvider()),
      ChangeNotifierProvider(create: (context) => ToolsProvider()),
      ChangeNotifierProvider(create: (context) => GroupProvider()),
      ChangeNotifierProvider(create: (context) => TabProvider()),
      ChangeNotifierProvider(create: (context) => ChatProvider()),
      ChangeNotifierProvider(create: (context) => DiscussionChatProvider()),
      ChangeNotifierProvider(create: (context) => NearMissProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: Constants.riskAssessments,
          theme: themeProvider.currentTheme,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
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
            Constants.createToolRoute: (context) =>
                const CreateExplainerScreen(),
            Constants.createGroupRoute: (context) => const CreateGroupScreen(),
            Constants.emailSignInRoute: (context) => const EmailLogin(),
            Constants.emailSignUpRoute: (context) => const EmailSignUp(),
            Constants.forgotPasswordRoute: (context) => const ForgotPassword(),
          },
        );
      },
    );
  }
}
