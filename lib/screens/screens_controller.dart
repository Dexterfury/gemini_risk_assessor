import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/screens/create_assessment_screen.dart';
import 'package:gemini_risk_assessor/screens/home_screen.dart';
import 'package:gemini_risk_assessor/screens/organisations_screen.dart';

class ScreensController extends StatefulWidget {
  const ScreensController({super.key});

  @override
  State<ScreensController> createState() => _ScreensControllerState();
}

class _ScreensControllerState extends State<ScreensController> {
  int _selectedIndex = 0;
  final List<Widget> _tabs = [
    const HomeScreen(),
    const OrganisationsGridScreen(),
  ];
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
        },
      ),

      // float action button to add new risk assessment
      floatingActionButton: _selectedIndex == 1
          ? null
          : OpenContainer(
              closedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(56.0),
                ),
              ),
              transitionType: ContainerTransitionType.fade,
              transitionDuration: const Duration(milliseconds: 500),
              closedColor: Theme.of(context).colorScheme.primary,
              closedBuilder: (context, openContainer) {
                return FloatingActionButton(
                  onPressed: openContainer,
                  child: const Icon(Icons.add),
                );
              },
              openBuilder: (context, _) {
                return const CreateAssessmentScreen();
              },
            ),

      // FloatingActionButton(
      //     onPressed: () {
      //       // navigate to create new risk assessment screen
      //       Navigator.pushNamed(context, Constants.createAssessmentRoute);
      //     },
      //     child: const Icon(Icons.add),
      //   ),
    );
  }
}
