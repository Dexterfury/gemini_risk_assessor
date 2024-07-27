import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';

class AnonymouseView extends StatelessWidget {
  const AnonymouseView({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            MainAppButton(
              icon: Icons.login,
              label: 'Sign In',
              onTap: () {
                // navigate to sign in screen and remove all routes
                navigationController(
                  context: context,
                  route: Constants.logingRoute,
                );
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const HelpScreen()));
              },
            )
          ],
        ),
      ),
    );
  }
}
