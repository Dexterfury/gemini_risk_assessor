import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
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
  }
}
