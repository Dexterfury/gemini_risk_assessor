import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/gemini_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/images_display.dart';
import 'package:gemini_risk_assessor/widgets/number_of_people.dart';
import 'package:gemini_risk_assessor/widgets/ppe_gridview_widget.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/widgets/weather_buttons.dart';
import 'package:provider/provider.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Create Assessment Screen',
      screenClass: 'CreateAssessmentScreen',
    );
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final title = args[Constants.title] as String;
    final groupID = args[Constants.groupArg] as String;
    final assessmentProvider = context.watch<AssessmentProvider>();

    final String docTitle = Constants.riskAssessment;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title),
        actions: [
          _buildResetIcon(assessmentProvider),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Add Project Images'),
                const SizedBox(height: 16),
                ImagesDisplay(assessmentProvider: assessmentProvider),
                const SizedBox(height: 32),
                _buildSectionTitle('Select Personal Protective Equipment'),
                const SizedBox(height: 16),
                const PpeGridViewWidget(),
                const SizedBox(height: 32),
                _buildSectionTitle('Select the Weather'),
                const SizedBox(height: 16),
                WeatherButtons(assessmentProvider: assessmentProvider),
                const SizedBox(height: 32),
                const NumberOfPeople(),
                const SizedBox(height: 32),
                InputField(
                  labelText: Constants.enterDescription,
                  hintText: Constants.enterDescription,
                  controller: _descriptionController,
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildGenerateButton(
                      context, assessmentProvider, groupID, docTitle),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FittedBox(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _buildResetIcon(AssessmentProvider assessmentProvider) {
    bool isResetIconVisible = assessmentProvider.shouldShowResetIcon() ||
        _descriptionController.text.isNotEmpty;
    if (!isResetIconVisible) return const SizedBox();

    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () => _showResetConfirmationDialog(assessmentProvider),
    );
  }

  void _showResetConfirmationDialog(AssessmentProvider assessmentProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Data'),
          content: const Text('Are you sure you want to clear all data?'),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () {
                assessmentProvider.resetCreationData();
                _descriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenerateButton(BuildContext context,
      AssessmentProvider assessmentProvider, String groupID, String docTitle) {
    return OpenContainer(
      closedBuilder: (context, action) {
        return GeminiButton(
          label: 'Generate',
          borderRadius: 25.0,
          onTap: () => _generateAssessment(
            context,
            assessmentProvider,
            groupID,
            docTitle,
            action,
          ),
        );
      },
      openBuilder: (context, action) {
        // navigate to screen depending on the clicked icon
        return AssessmentDetailsScreen(
          appBarTitle: docTitle,
          groupID: groupID,
          isAdmin: true,
        );
      },
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 500),
      closedElevation: AppTheme.cardElevation,
      closedColor: Theme.of(context).cardColor,
      openElevation: 4,
    );
  }

  void _generateAssessment(
      BuildContext context,
      AssessmentProvider assessmentProvider,
      String groupID,
      String docTitle,
      VoidCallback action) async {
    final desc = _descriptionController.text;
    // if both images and description is empty return
    if (desc.isEmpty || desc.length < 10) {
      showSnackBar(
        context: context,
        message: 'Please add a description of at least 10 characters',
      );
      return;
    }

    final authProvider = context.read<AuthenticationProvider>();
    final creatorID = authProvider.userModel!.uid;
    final stopwatch = Stopwatch()..start();
    // show my alert dialog for loading
    MyDialogs.showMyAnimatedDialog(
      context: context,
      title: 'Generating',
      loadingIndicator:
          const SizedBox(height: 100, width: 100, child: LoadingPPEIcons()),
    );

    await assessmentProvider.submitPrompt(
      context: context,
      creatorID: creatorID,
      groupID: groupID,
      description: _descriptionController.text,
      docTitle: docTitle,
      onSuccess: () async {
        stopwatch.stop();
        await AnalyticsHelper.logCustomEvent('risk_assessment_generation_time',
            parameters: {
              'duration_ms': stopwatch.elapsedMilliseconds,
            });
        // pop the loading dialog
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 500)).whenComplete(action);
      },
      onError: (error) async {
        stopwatch.stop();
        await AnalyticsHelper.logCustomEvent('risk_assessment_generation_time',
            parameters: {
              'duration_ms': stopwatch.elapsedMilliseconds,
            });
        // pop the loading dialog
        Navigator.pop(context);
        showSnackBar(
          context: context,
          message: error,
        );
      },
    );
  }
}
