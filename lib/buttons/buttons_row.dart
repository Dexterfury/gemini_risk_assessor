import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/screens/discussion_screen.dart';
import 'package:gemini_risk_assessor/screens/dsti_screen.dart';
import 'package:gemini_risk_assessor/screens/risk_assessments_screen.dart';
import 'package:gemini_risk_assessor/screens/tools_screen.dart';
import 'package:provider/provider.dart';

class ButtonsRow extends StatelessWidget {
  const ButtonsRow({
    super.key,
    required this.orgID,
  });

  final String orgID;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildButton(Icons.assignment_add, orgID, 'DSTI'),
              const SizedBox(
                width: 5,
              ),
              buildButton(Icons.assignment_late_outlined, orgID, 'Assessments'),
              const SizedBox(
                width: 5,
              ),
              buildButton(
                Icons.handyman,
                orgID,
                Constants.tools,
              ),
              const SizedBox(
                width: 5,
              ),
              buildButton(
                FontAwesomeIcons.peopleGroup,
                orgID,
                'Discussions',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildButton(IconData icon, String orgID, String label) {
  return OpenContainer(
    //closedColor: Colors.transparent,
    closedBuilder: (context, action) {
      return SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        child: MaterialButton(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onPressed: () async {
            // set search data depending on the clicked icon
            await _setSearchData(context, icon);
            action();
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
      return _navigateToScreen(icon, orgID);
    },
    transitionType: ContainerTransitionType.fadeThrough,
    transitionDuration: const Duration(milliseconds: 500),
    closedShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    closedElevation: 4,
    openElevation: 4,
  );
}

Widget _navigateToScreen(IconData icon, String orgID) {
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
      return DiscussionScreen(
        orgID: orgID,
      );
  }
}

_setSearchData(
  BuildContext context,
  IconData icon,
) async {
  if (icon == Icons.assignment_add) {
    await context.read<TabProvider>().dataSearch(0);
  } else if (icon == Icons.assignment_late_outlined) {
    await context.read<TabProvider>().dataSearch(1);
  } else {
    await context.read<TabProvider>().dataSearch(2);
  }
}
