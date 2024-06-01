import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/widgets/assessment_images.dart';
import 'package:gemini_risk_assessor/widgets/generate_button.dart';
import 'package:gemini_risk_assessor/widgets/gradient_orb.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/number_of_people.dart';
import 'package:gemini_risk_assessor/widgets/ppe_gridview_widget.dart';
import 'package:gemini_risk_assessor/widgets/project_discription_field.dart';
import 'package:gemini_risk_assessor/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    final assessmentProvider = context.watch<AssessmentProvider>();
    return Scaffold(
      appBar: const MyAppBar(
        title: Constants.createAssessment,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeadingTitleWidget(
                title: 'Add Project images',
              ),
              const SizedBox(
                height: 10,
              ),
              const AssessmentImages(),
              const SizedBox(
                height: 20,
              ),
              const HeadingTitleWidget(
                title: 'Select Personal Protective Equipment',
              ),
              const SizedBox(
                height: 10,
              ),
              const PpeGridViewWidget(),
              const SizedBox(
                height: 20,
              ),
              const NumberOfPeople(),
              const SizedBox(
                height: 20,
              ),
              const HeadingTitleWidget(
                title: 'What do you want to do?',
              ),
              const SizedBox(
                height: 10,
              ),
              const ProjectDiscriptionField(
                labelText: Constants.enterYourName,
                hintText: Constants.enterYourName,
              ),
              const SizedBox(
                height: 10,
              ),
              const ProjectDiscriptionField(
                labelText: Constants.enterDescription,
                hintText: Constants.enterDescription,
              ),
              const SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GenerateButton(
                  widget: const Icon(Icons.create),
                  label: 'Generate Assessment',
                  onTap: () async {
                    await assessmentProvider.submitPrompt().then((_) async {
                      if (!context.mounted) return;
                      // if (viewModel.recipe != null) {
                      //   bool? shouldSave = await showDialog<bool>(
                      //     context: context,
                      //     barrierDismissible: false,
                      //     builder: (context) => RecipeDialogScreen(
                      //       recipe: viewModel.recipe!,
                      //       actions: [
                      //         MarketplaceButton(
                      //           onPressed: () {
                      //             Navigator.of(context).pop(true);
                      //           },
                      //           buttonText: "Save Recipe",
                      //           icon: Symbols.save,
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      //   if (shouldSave != null && shouldSave) {
                      //     viewModel.saveRecipe();
                      //   }
                      // }
                    });
                  },
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
