import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/screens/home_screen.dart';
import 'package:gemini_risk_assessor/screens/organisations_screen.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:provider/provider.dart';

class ScreensController extends StatefulWidget {
  const ScreensController({super.key});

  @override
  State<ScreensController> createState() => _ScreensControllerState();
}

class _ScreensControllerState extends State<ScreensController>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Widget> _tabs = [
    const HomeScreen(),
    const OrganisationsScreen(),
  ];

  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _animation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    super.initState();
  }

  // void _navigateToCreateAssessment(BuildContext context) {
  //   OpenContainer(
  //     closedShape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.all(Radius.circular(56.0)),
  //     ),
  //     transitionType: ContainerTransitionType.fade,
  //     transitionDuration: const Duration(milliseconds: 500),
  //     closedColor: Theme.of(context).colorScheme.primary,
  //     closedBuilder: (context, openContainer) {
  //       return FloatingActionButton(
  //         onPressed: openContainer,
  //         child: const Icon(Icons.add),
  //       );
  //     },
  //     openBuilder: (context, _) {
  //       return const CreateAssessmentScreen();
  //     },
  //   );
  // }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Organisations',
          ),
        ],
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
          // set isPersonal
          context
              .read<AssessmentProvider>()
              .setIsPersonal(isPersonal: value == 0);
        },
      ),

      // float action button to add new risk assessment
      floatingActionButton: _selectedIndex == 1
          ? null
          : FloatingActionBubble(
              items: [
                Bubble(
                  title: "Tools Explainer",
                  iconColor: Colors.white,
                  bubbleColor: Theme.of(context).colorScheme.primary,
                  icon: Icons.handyman,
                  titleStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  onPress: () {
                    _animationController.reverse();
                    navigationController(
                      context: context,
                      route: Constants.createToolRoute,
                    );
                  },
                ),
                Bubble(
                  title: "Risk Assessment",
                  iconColor: Colors.white,
                  bubbleColor: Theme.of(context).colorScheme.primary,
                  icon: Icons.assignment_late_outlined,
                  titleStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  onPress: () {
                    _animationController.reverse();
                    navigationController(
                      context: context,
                      route: Constants.createAssessmentRoute,
                      argument: Constants.createAssessment,
                    );
                  },
                ),
                Bubble(
                  title: "Daily Safety Tasks Instructions",
                  iconColor: Colors.white,
                  bubbleColor: Theme.of(context).colorScheme.primary,
                  icon: Icons.assignment_add,
                  titleStyle:
                      const TextStyle(fontSize: 16, color: Colors.white),
                  onPress: () {
                    _animationController.reverse();
                    //context.read<AssessmentProvider>().emptyAssessmentModel();
                    navigationController(
                      context: context,
                      route: Constants.createAssessmentRoute,
                      argument: Constants.createDsti,
                    );
                  },
                ),
              ],
              animation: _animation,
              onPress: () => _animationController.isCompleted
                  ? _animationController.reverse()
                  : _animationController.forward(),
              iconColor: Colors.white,
              animatedIconData: AnimatedIcons.menu_close, // Animated icon
              backGroundColor: Theme.of(context).colorScheme.primary,
            ),
    );
  }
}
