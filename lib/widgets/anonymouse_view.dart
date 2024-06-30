import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';

class AnonymouseView extends StatelessWidget {
  const AnonymouseView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please Sign In to view organisations',
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
              },
            )
          ],
        ),
      ),
    );
  }
}
