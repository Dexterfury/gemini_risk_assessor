import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';

class OrganisationFabButton extends StatelessWidget {
  const OrganisationFabButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () {
        // navigate to create organisation screen
        navigationController(
          context: context,
          route: Constants.createOrganisationRoute,
        );
      },
      label: const Text(
        'Create Organisation',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      icon: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
