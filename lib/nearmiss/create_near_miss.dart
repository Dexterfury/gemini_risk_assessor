import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/gemini_button.dart';
import 'package:gemini_risk_assessor/nearmiss/nm_text_input_field.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:gemini_risk_assessor/widgets/icon_container.dart';
import 'package:provider/provider.dart';

class CreateNearMiss extends StatefulWidget {
  const CreateNearMiss({super.key});

  @override
  State<CreateNearMiss> createState() => _CreateNearMissState();
}

class _CreateNearMissState extends State<CreateNearMiss> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nearMissController = TextEditingController();
  final dateTimeController = BoardDateTimeTextController();

  @override
  dispose() {
    _descriptionController.dispose();
    _nearMissController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nearMissProvider = context.read<NearMissProvider>();
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
                    icon: FontAwesomeIcons.calendarDays,
                    containerColor: Colors.orangeAccent,
                  ),
                  SizedBox(
                    width: 150,
                    child: Expanded(
                      child: BoardDateTimeInputField(
                        controller: dateTimeController,
                        initialDate: DateTime.now(),
                        pickerType: DateTimePickerType.datetime,
                        options: const BoardDateTimeOptions(
                          languages: BoardPickerLanguages.en(),
                        ),
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        onChanged: (date) {
                          print('onchanged: $date');
                        },
                        onFocusChange: (val, date, text) {
                          print('on focus changed date: $val, $date, $text');
                        },
                      ),
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
                controller: _nearMissController,
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
              // create assessment button
              Align(
                alignment: Alignment.centerRight,
                child: GeminiButton(
                  label: 'Generate',
                  borderRadius: 15.0,
                  onTap: () async {},
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
