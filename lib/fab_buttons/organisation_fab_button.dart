import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/screens/create_organisation_screen.dart';

class OrganisationFabButton extends StatelessWidget {
  const OrganisationFabButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (BuildContext context, VoidCallback _) {
        return const CreateOrganisationScreen();
      },
      closedElevation: 6.0,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      closedColor: Theme.of(context).colorScheme.primary,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        return SizedBox(
          height: 56.0,
          width: 56.0,
          child: Center(
            child: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        );
      },
    );

    // FloatingActionButton.extended(
    //   backgroundColor: Theme.of(context).colorScheme.primary,
    //   onPressed: () {
    //     // navigate to create organisation screen
    //     navigationController(
    //       context: context,
    //       route: Constants.createOrganisationRoute,
    //     );
    //   },
    //   label: const Text(
    //     'Create Organisation',
    //     style: TextStyle(
    //       color: Colors.white,
    //     ),
    //   ),
    //   icon: const Icon(
    //     Icons.add,
    //     color: Colors.white,
    //   ),
    // );
  }
}
