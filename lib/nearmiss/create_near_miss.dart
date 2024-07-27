import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/buttons/gemini_button.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_details_screen.dart';
import 'package:gemini_risk_assessor/nearmiss/nm_text_input_field.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/icon_container.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateNearMiss extends StatefulWidget {
  const CreateNearMiss({
    super.key,
    required this.groupID,
  });

  final String groupID;

  @override
  State<CreateNearMiss> createState() => _CreateNearMissState();
}

class _CreateNearMissState extends State<CreateNearMiss> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final _dateTimeController = BoardDateTimeTextController();

  String _dateTime = '';

  @override
  dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initializeDate();
    super.initState();
  }

  // set the current date to dateTime string
  void initializeDate() {
    // wait for widget to be built
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // set the current date to dateTime string
      _dateTime = formatDate(DateTime.now().toString());
      log('date: $_dateTime');
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
        title: 'Near Miss Report',
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconContainer(
                    icon: FontAwesomeIcons.calendarDay,
                    containerColor: Colors.orangeAccent,
                  ),
                  SizedBox(
                    width: 150,
                    child: BoardDateTimeInputField(
                      controller: _dateTimeController,
                      initialDate: DateTime.now(),
                      pickerType: DateTimePickerType.datetime,
                      options: const BoardDateTimeOptions(
                        languages: BoardPickerLanguages.en(),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (date) {
                        //print('onchanged: $date');
                      },
                      onFocusChange: (val, date, text) {
                        _dateTime = text;
                        log('DateTime: $_dateTime');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 40,
              ),

              // location field
              NmTextInputField(
                labelText: 'Location of Near Miss',
                hintText: 'Enter Near Miss Location',
                controller: _locationController,
              ),

              const SizedBox(
                height: 20,
              ),
              // description field
              NmTextInputField(
                labelText: 'Description of Near Miss',
                hintText: 'Enter Near Description',
                controller: _descriptionController,
              ),

              const SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: OpenContainer(
                  closedBuilder: (context, action) {
                    return GeminiButton(
                      label: 'Generate',
                      borderRadius: 15.0,
                      onTap: () async {
                        final nearMissProvider =
                            context.read<NearMissProvider>();
                        final location = _locationController.text;
                        final desc = _descriptionController.text;

                        if (desc.isEmpty || desc.length < 10) {
                          showSnackBar(
                            context: context,
                            message:
                                'Please add a description of at least 10 characters',
                          );
                          return;
                        }

                        if (location.isEmpty || location.length < 3) {
                          showSnackBar(
                            context: context,
                            message:
                                'Please add a location of at least 10 characters',
                          );
                          return;
                        }

                        final authProvider =
                            context.read<AuthenticationProvider>();
                        final creatorID = authProvider.userModel!.uid;

                        // show my alert dialog for loading
                        MyDialogs.showMyAnimatedDialog(
                          context: context,
                          title: 'Generating',
                          loadingIndicator: const SizedBox(
                              height: 100,
                              width: 100,
                              child: LoadingPPEIcons()),
                        );

                        await nearMissProvider.submitPromptNearMiss(
                          creatorID: creatorID,
                          groupID: widget.groupID,
                          description: _descriptionController.text,
                          dateTime: _dateTime,
                          location: location,
                          onSuccess: () {
                            // pop the loading dialog
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 500))
                                .whenComplete(action);
                          },
                          onError: (error) {
                            showSnackBar(
                              context: context,
                              message: error,
                            );
                          },
                        );
                      },
                    );
                  },
                  openBuilder: (context, action) {
                    // navigate to screen depending on the clicked icon
                    return NearMissDetailsScreen();
                  },
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  transitionType: ContainerTransitionType.fadeThrough,
                  transitionDuration: const Duration(milliseconds: 500),
                  closedElevation: cardElevation,
                  openElevation: 4,
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
