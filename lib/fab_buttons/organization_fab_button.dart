import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/screens/create_organization_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';

class OrganizationFabButton extends StatelessWidget {
  const OrganizationFabButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedBuilder: (context, action) {
        return FloatingActionButton.extended(
          backgroundColor: Theme.of(context).primaryColor,
          label: const Text(
            'Create Organization',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: action,
        );
      },
      openBuilder: (context, action) {
        // navigate to people screen
        return const CreateOrganizationScreen();
      },
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      closedColor: Theme.of(context).primaryColor,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 500),
      closedElevation: cardElevation,
      openElevation: 4,
    );

    // OpenContainer(
    //   transitionType: ContainerTransitionType.fadeThrough,
    //   transitionDuration: const Duration(milliseconds: 500),
    //   openBuilder: (BuildContext context, VoidCallback _) {
    //     return const CreateOrganizationScreen();
    //   },
    //   closedElevation: cardElevation,
    //   closedShape: const RoundedRectangleBorder(
    //     borderRadius: BorderRadius.all(
    //       Radius.circular(15),
    //     ),
    //   ),
    //   closedColor: Theme.of(context).colorScheme.primary,
    //   closedBuilder: (BuildContext context, VoidCallback openContainer) {
    //     return FloatingActionButton(onPressed: onPressed)

    //     SizedBox(
    //       height: 56.0,
    //       width: 56.0,
    //       child: Center(
    //         child: Icon(
    //           Icons.add,
    //           color: Theme.of(context).colorScheme.onPrimary,
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
