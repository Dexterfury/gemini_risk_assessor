import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/action_button.dart';
import 'package:gemini_risk_assessor/widgets/display_signature.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class BottonButtonsField extends StatelessWidget {
  const BottonButtonsField({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            assessmentProvider.signatureImage == null
                ? MainAppButton(
                    icon: Icons.fingerprint,
                    label: "Add Signature",
                    onTap: () {
                      // show signature dialog
                      MyDialogs.showMyAnimatedDialog(
                          context: context,
                          title: 'Signature',
                          content: '',
                          signatureInput: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: SfSignaturePad(
                              key: assessmentProvider.signatureGlobalKey,
                              backgroundColor: Colors.white,
                              strokeColor: Colors.black,
                              minimumStrokeWidth: 1.0,
                              maximumStrokeWidth: 4.0,
                              onDrawEnd: () =>
                                  assessmentProvider.setHasSigned(true),
                            ),
                          ),
                          actions: [
                            ActionButton(
                              label: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ActionButton(
                              label: const Text(
                                'Save',
                              ),
                              onPressed: () {
                                if (!assessmentProvider.hasSigned) {
                                  showSnackBar(
                                      context: context,
                                      message:
                                          'Please sign the document first.');
                                  return;
                                }
                                assessmentProvider
                                    .saveSignature()
                                    .whenComplete(() {
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ]);
                    })
                : DisplaySignature(assessmentProvider: assessmentProvider),
            const SizedBox(
              width: 10,
            ),
            MainAppButton(
                icon: Icons.save,
                label: "Save Assessment",
                onTap: () async {
                  if (assessmentProvider.signatureImage == null) {
                    showSnackBar(
                      context: context,
                      message: 'Please sign the document first.',
                    );
                    return;
                  }

                  // show my alert dialog for loading
                  MyDialogs.showMyAnimatedDialog(
                    context: context,
                    title: 'Saving the document',
                    content: 'Please wait...',
                    loadingIndicator: const SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator()),
                  );
                  // create the pdf file and save to local storage
                  assessmentProvider.createPdfAndSave().whenComplete(() async {
                    // close the loading dialog
                    Navigator.pop(context);

                    // pop the current screen with save as true
                    Navigator.of(context).pop(true);

                    // // navigate to home screen
                    // navigationController(
                    //   context: context,
                    //   route: Constants.screensControllerRoute,
                    // );

                    // await OpenFile.open(
                    //     (assessmentProvider.pdfAssessmentFile!.path));
                  });
                }),
          ],
        );
      },
    );
  }
}
