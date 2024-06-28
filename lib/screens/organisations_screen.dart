import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class OrganisationsScreen extends StatelessWidget {
  const OrganisationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = context.watch<AuthProvider>().isUserAnonymous();
    return Scaffold(
      appBar: MyAppBar(
        title: 'Organisations',
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        actions: DisplayUserImage(
          radius: 20,
          isViewOnly: true,
          authProvider: context.watch<AuthProvider>(),
          onPressed: () {},
        ),
      ),
      body: isAnonymous
          ? Padding(
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
                      widget: const Icon(
                        Icons.login,
                        color: Colors.white,
                      ),
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
            )
          : const Center(
              child: Text('Organisations'),
            ),
    );
  }
}
