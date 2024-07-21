import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/utilities/custom_floating_action_button.dart';
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
    return CustomFloatingActionBubble(
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
      iconColor: Colors.black,
      backGroundColor: Colors.white,
      closedImage:
          AssetImage(AssetsManager.geminiLogo1), // Add your image asset
      openIcon: Icons.close, // Icon to show when open
    );
  }
}
