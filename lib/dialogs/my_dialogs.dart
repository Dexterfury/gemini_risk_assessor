import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/ppe_model.dart';
import 'package:gemini_risk_assessor/widgets/people.dart';

class MyDialogs {
  // general dialog
  static void showMyAnimatedDialog({
    required BuildContext context,
    required String title,
    String content = '',
    Widget? loadingIndicator, // loading indicator
    Widget? signatureInput, // signature field
    List<Widget>? actions,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
              child: AlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                content: getContent(
                  content,
                  loadingIndicator,
                  signatureInput,
                ),
                actions: actions,
              ),
            ));
      },
    );
  }

// edit dialogs
  static void showMyEditAnimatedDialog({
    required BuildContext context,
    required String title,
    required String content,
    String hintText = '',
    required String textAction,
    required Function(bool, String) onActionTap,
  }) {
    TextEditingController controller = TextEditingController(text: hintText);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
              child: AlertDialog(
                title: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                content: TextField(
                  controller: controller,
                  maxLength: content == Constants.changeName ? 20 : 500,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: hintText,
                    counterText: '',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onActionTap(
                        false,
                        controller.text,
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onActionTap(
                        true,
                        controller.text,
                      );
                    },
                    child: Text(textAction),
                  ),
                ],
              ),
            ));
      },
    );
  }

  // people dialog
  static void showAnimatedPeopleDialog({
    required BuildContext context,
    required UserViewType userViewType,
    List<Widget>? actions,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation1),
              child: AlertDialog(
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width,
                  child: People(
                    userViewType: userViewType,
                  ),
                ),
                actions: actions ?? [],
              ),
            ));
      },
    );
  }

  static getContent(
    String content,
    Widget? loadingIndicator,
    Widget? signatureInput,
  ) {
    if (loadingIndicator != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingIndicator,
        ],
      );
    } else if (signatureInput != null) {
      return signatureInput;
    } else {
      return Text(
        content,
        textAlign: TextAlign.center,
      );
    }
  }
}

class LoadingPPEIcons extends StatefulWidget {
  const LoadingPPEIcons({
    super.key,
  });

  @override
  State<LoadingPPEIcons> createState() => _LoadingPPEIconsState();
}

class _LoadingPPEIconsState extends State<LoadingPPEIcons> {
  late Timer _timer;
  int _currentIconIndex = 0;
  late List<PpeModel> _ppeIcons;

  @override
  void initState() {
    super.initState();
    _ppeIcons = Constants.getPPEIcons(radius: 30.0);
    _ppeIcons.removeLast(); // Remove the "Other" option
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIconIndex = Random().nextInt(_ppeIcons.length);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ppeIcons[_currentIconIndex].icon,
          const SizedBox(height: 8),
          Text(
            _ppeIcons[_currentIconIndex].label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
