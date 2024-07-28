import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/create_group_screen.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:provider/provider.dart';

class GroupFabButton extends StatelessWidget {
  const GroupFabButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isAnonymous =
        context.read<AuthenticationProvider>().isUserAnonymous();
    return isAnonymous
        ? const SizedBox()
        : OpenContainer(
            closedBuilder: (context, action) {
              return FloatingActionButton.extended(
                  backgroundColor: AppTheme.getFabBtnTheme(context),
                  label: const Text(
                    'Create Group',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await context
                        .read<GroupProvider>()
                        .clearAwaitingApprovalList();
                    action();
                  });
            },
            openBuilder: (context, action) {
              // navigate to people screen
              return const CreateGroupScreen();
            },
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            closedColor: Theme.of(context).primaryColor,
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 500),
            closedElevation: AppTheme.cardElevation,
            openElevation: 4,
          );

    // OpenContainer(
    //   transitionType: ContainerTransitionType.fadeThrough,
    //   transitionDuration: const Duration(milliseconds: 500),
    //   openBuilder: (BuildContext context, VoidCallback _) {
    //     return const CreateGroupScreen();
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
