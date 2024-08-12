import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/nearmiss/near_misses_screen.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/tools/tools_screen.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class ButtonsRow extends StatelessWidget {
  const ButtonsRow({
    super.key,
    required this.groupID,
    required this.isAdmin,
    required this.isMember,
  });

  final String groupID;
  final bool isAdmin;
  final bool isMember;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildButton(
                Icons.assignment_late_outlined,
                groupID,
                'Assessments',
                isAdmin,
                isMember,
              ),
              const SizedBox(
                width: 5,
              ),
              buildButton(
                Icons.handyman,
                groupID,
                Constants.toolsExplainer,
                isAdmin,
                isMember,
              ),
              const SizedBox(
                width: 5,
              ),
              buildButton(
                FontAwesomeIcons.circleExclamation,
                groupID,
                Constants.nearMisses,
                isAdmin,
                isMember,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildButton(
  IconData icon,
  String orgID,
  String label,
  bool isAdmin,
  bool isMember,
) {
  return OpenContainer(
    //closedColor: Colors.transparent,
    closedBuilder: (context, action) {
      return SizedBox(
        height: 60,
        width: MediaQuery.of(context).size.width / 4,
        child: MaterialButton(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            if (!isMember) {
              showSnackBar(
                context: context,
                message: 'Join Group to view this screen',
              );
            } else {
              action();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FittedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    openBuilder: (context, action) {
      // navigate to screen depending on the clicked icon
      return _navigateToScreen(
        icon,
        orgID,
        isAdmin,
      );
    },
    transitionType: ContainerTransitionType.fadeThrough,
    transitionDuration: const Duration(milliseconds: 500),
    closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    closedElevation: AppTheme.cardElevation,
    openElevation: 4,
  );
}

Widget _navigateToScreen(
  IconData icon,
  String orgID,
  bool isAdmin,
) {
  switch (icon) {
    case Icons.assignment_late_outlined:
      return RiskAssessmentsScreen(groupID: orgID, isAdmin: isAdmin);
    case Icons.handyman:
      return ToolsScreen(
        groupID: orgID,
        isAdmin: isAdmin,
      );
    default:
      return NearMissesScreen(
        groupID: orgID,
        isAdmin: isAdmin,
      );
  }
}
