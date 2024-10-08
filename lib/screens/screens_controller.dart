import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/group_fab_button.dart';
import 'package:gemini_risk_assessor/providers/tab_provider.dart';
import 'package:gemini_risk_assessor/screens/home_screen.dart';
import 'package:gemini_risk_assessor/groups/groups_screen.dart';
import 'package:gemini_risk_assessor/buttons/my_fab_button.dart';
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
    const GroupsScreen(),
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
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.peopleGroup),
            label: 'Groups',
          ),
        ],
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
          if (_selectedIndex == 1 && mounted) {
            // set search hintext
            context.read<TabProvider>().setSearchHintText('Search Groups');
          }
        },
      ),

      // float action button to add new risk assessment
      floatingActionButton: _selectedIndex == 1
          ? const GroupFabButton()
          : MyFabButton(
              animationController: _animationController,
              animation: _animation,
            ),
    );
  }
}
