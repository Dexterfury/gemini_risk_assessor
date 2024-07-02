import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';

class MyFabButton extends StatelessWidget {
  const MyFabButton({
    super.key,
    required AnimationController animationController,
    required Animation<double> animation,
    this.organisationID = '',
  })  : _animationController = animationController,
        _animation = animation;

  final AnimationController _animationController;
  final Animation<double> _animation;
  final String organisationID;

  @override
  Widget build(BuildContext context) {
    return FloatingActionBubble(
      items: [
        Bubble(
          title: "Tools Explainer",
          iconColor: Colors.white,
          bubbleColor: Theme.of(context).colorScheme.primary,
          icon: Icons.handyman,
          titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
          onPress: () {
            _animationController.reverse();
            navigationController(
              context: context,
              route: Constants.createToolRoute,
              titleArg: Constants.toolExplainer,
              orgArg: organisationID,
            );
          },
        ),
        Bubble(
          title: "Risk Assessment",
          iconColor: Colors.white,
          bubbleColor: Theme.of(context).colorScheme.primary,
          icon: Icons.assignment_late_outlined,
          titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
          onPress: () {
            _animationController.reverse();
            navigationController(
              context: context,
              route: Constants.createAssessmentRoute,
              titleArg: Constants.createAssessment,
              orgArg: organisationID,
            );
          },
        ),
        Bubble(
          title: "Daily Safety Tasks Instructions",
          iconColor: Colors.white,
          bubbleColor: Theme.of(context).colorScheme.primary,
          icon: Icons.assignment_add,
          titleStyle: const TextStyle(fontSize: 16, color: Colors.white),
          onPress: () {
            _animationController.reverse();
            //context.read<AssessmentProvider>().emptyAssessmentModel();
            navigationController(
              context: context,
              route: Constants.createAssessmentRoute,
              titleArg: Constants.createDsti,
              orgArg: organisationID,
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
    );
  }
}
