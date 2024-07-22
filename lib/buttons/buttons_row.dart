import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/nearmiss/near_misses_screen.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:gemini_risk_assessor/screens/tools_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class ButtonsRow extends StatelessWidget {
  const ButtonsRow({
    super.key,
    required this.orgID,
    required this.isAdmin,
    required this.isMember,
  });

  final String orgID;
  final bool isAdmin;
  final bool isMember;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildButton(
                Icons.assignment_add,
                orgID,
                'DSTI',
                isAdmin,
                isMember,
              ),
              const SizedBox(
                width: 5,
              ),
              buildButton(
                Icons.assignment_late_outlined,
                orgID,
                'Assessments',
                isAdmin,
                isMember,
              ),
              const SizedBox(
                width: 5,
              ),
              buildButton(
                Icons.handyman,
                orgID,
                Constants.tools,
                isAdmin,
                isMember,
              ),
              const SizedBox(
                width: 5,
              ),
              buildButton(
                FontAwesomeIcons.circleExclamation,
                orgID,
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
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () {
            if (!isMember) {
              showSnackBar(
                context: context,
                message: 'Join Organization to view this screen',
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
    closedShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    closedElevation: cardElevation,
    openElevation: 4,
  );
}

Widget _navigateToScreen(
  IconData icon,
  String orgID,
  bool isAdmin,
) {
  switch (icon) {
    case Icons.assignment_add:
      return DSTIScreen(
        orgID: orgID,
      );
    case Icons.assignment_late_outlined:
      return RiskAssessmentsScreen(orgID: orgID);
    case Icons.handyman:
      return ToolsScreen(
        orgID: orgID,
      );
    default:
      return NearMissesScreen(
        orgID: orgID,
        isAdmin: isAdmin,
      );
  }
}
