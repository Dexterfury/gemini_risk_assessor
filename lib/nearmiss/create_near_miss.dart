import 'package:animations/animations.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/buttons/gemini_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase_methods/analytics_helper.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_details_screen.dart';
import 'package:gemini_risk_assessor/nearmiss/nm_text_input_field.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/icon_container.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateNearMiss extends StatefulWidget {
  const CreateNearMiss({
    Key? key,
    required this.groupID,
  }) : super(key: key);

  final String groupID;

  @override
  State<CreateNearMiss> createState() => _CreateNearMissState();
}

class _CreateNearMissState extends State<CreateNearMiss> {
  final TextEditingController _descriptionController = TextEditingController();
  final _dateTimeController = BoardDateTimeTextController();
  final BoardDateTimeInputFocusNode _dateTimeFocusNode =
      BoardDateTimeInputFocusNode(); // Create a FocusNode

  String _dateTime = '';

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateTimeFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Create Near Miss',
      screenClass: 'CreateNearMiss',
    );
    super.initState();
    initializeDate();
  }

  void initializeDate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // remove focus from decription textfield
      FocusScope.of(context).unfocus();
      _dateTime = formatDate(DateTime.now().toString());
      setState(() {});
    });
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: const BackButton(),
        title: 'Create Near Miss Report',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 32),
                _buildDescriptionField(),
                const SizedBox(height: 40),
                _buildGenerateButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconContainer(
            icon: FontAwesomeIcons.calendarDay,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date and Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                BoardDateTimeInputField(
                  controller: _dateTimeController,
                  initialDate: DateTime.now(),
                  pickerType: DateTimePickerType.datetime,
                  options: const BoardDateTimeOptions(
                    languages: BoardPickerLanguages.en(),
                  ),
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (date) {
                    setState(() {
                      _dateTime = formatDate(date.toString());
                    });
                  },
                  onFocusChange: (val, date, text) {
                    setState(() {
                      _dateTime = text;
                    });
                  },
                  focusNode: _dateTimeFocusNode, // Attach the FocusNode
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description of Near Miss',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        NmTextInputField(
          labelText: 'Describe what happened',
          hintText: 'Enter a detailed description of the near miss incident',
          controller: _descriptionController,
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: OpenContainer(
        closedBuilder: (context, action) {
          return GeminiButton(
            label: 'Generate Report',
            borderRadius: 25.0,
            onTap: () => _generateReport(context, action),
          );
        },
        openBuilder: (context, action) {
          return NearMissDetailsScreen(dateTimeFocusNode: _dateTimeFocusNode);
        },
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        closedElevation: AppTheme.cardElevation,
        openElevation: 4,
      ),
    );
  }

  void _generateReport(BuildContext context, VoidCallback action) async {
    final nearMissProvider = context.read<NearMissProvider>();
    final desc = _descriptionController.text;

    if (desc.isEmpty || desc.length < 10) {
      showSnackBar(
        context: context,
        message: 'Please add a description of at least 10 characters',
      );
      return;
    }

    final authProvider = context.read<AuthenticationProvider>();
    final creatorID = authProvider.userModel!.uid;

    MyDialogs.showMyAnimatedDialog(
      context: context,
      title: 'Generating Report',
      loadingIndicator: const SizedBox(
        height: 100,
        width: 100,
        child: LoadingPPEIcons(),
      ),
    );

    await nearMissProvider.submitPromptNearMiss(
      creatorID: creatorID,
      groupID: widget.groupID,
      description: desc,
      dateTime: _dateTime,
      onSuccess: () async {
        await AnalyticsHelper.logReportNearMiss();
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
          action();
          _dateTimeFocusNode
              .unfocus(); // Unfocus the DateTime field after generating the report
        });
      },
      onError: (error) {
        Navigator.pop(context);
        showSnackBar(
          context: context,
          message: error,
        );
      },
    );
  }
}
