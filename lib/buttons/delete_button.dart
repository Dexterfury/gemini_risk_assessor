import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/tools/tool_model.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:provider/provider.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.groupID,
    required this.generationType,
    this.assessment,
    this.tool,
  });

  final String groupID;
  final GenerationType generationType;
  final AssessmentModel? assessment;
  final ToolModel? tool;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    Widget buttonWidget() {
      return MainAppButton(
        icon: FontAwesomeIcons.deleteLeft,
        label: ' Delete ',
        contanerColor: Colors.red,
        borderRadius: 15.0,
        onTap: () async {
          // show my alert dialog for loading
          MyDialogs.showMyAnimatedDialog(
            context: context,
            title: 'Deleting...',
            loadingIndicator: const SizedBox(
              height: 100,
              width: 100,
              child: LoadingPPEIcons(),
            ),
          );

          if (assessment != null) {
            await FirebaseMethods.deleteAssessment(
              currentUserID: uid,
              groupID: groupID,
              assessment: assessment!,
              onSuccess: () {
                // pop the loading dialog
                Navigator.pop(context);
                Future.delayed(const Duration(seconds: 1)).whenComplete(() {
                  showSnackBar(
                    context: context,
                    message: 'Successful Deleted',
                  );
                  // pop the screen
                  Navigator.pop(context);
                });
              },
              onError: (error) {
                // pop the loading dialog
                Navigator.pop(context);
                showSnackBar(
                  context: context,
                  message: error.toString(),
                );
              },
            );
          } else {
            await FirebaseMethods.deleteTool(
              currentUserID: uid,
              groupID: groupID,
              tool: tool!,
              onSuccess: () {
                // pop the loading dialog
                Navigator.pop(context);
                Future.delayed(const Duration(seconds: 1)).whenComplete(() {
                  showSnackBar(
                    context: context,
                    message: 'Successful Deleted',
                  );
                  // pop the screen
                  Navigator.pop(context);
                });
              },
              onError: (error) {
                // pop the loading dialog
                Navigator.pop(context);
                showSnackBar(
                  context: context,
                  message: error.toString(),
                );
              },
            );
          }
        },
      );
    }

    return buttonWidget();
  }
}
