import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:gemini_risk_assessor/widgets/people.dart';

class MyDialogs {
  // general dialog
  static void showMyAnimatedDialog({
    required BuildContext context,
    required String title,
    required String content,
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
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    loadingIndicator ?? const SizedBox(),
                    signatureInput ?? const SizedBox(),
                  ],
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
}
