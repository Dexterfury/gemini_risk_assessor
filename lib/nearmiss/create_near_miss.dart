import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/buttons/gemini_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/near_miss_provider.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:gemini_risk_assessor/widgets/add_image.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/widgets/title_widget.dart';
import 'package:provider/provider.dart';

class CreateNearMiss extends StatefulWidget {
  const CreateNearMiss({super.key});

  @override
  State<CreateNearMiss> createState() => _CreateNearMissState();
}

class _CreateNearMissState extends State<CreateNearMiss> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nearMissProvider = context.watch<NearMissProvider>();
    return Scaffold(
      appBar: MyAppBar(
        leading: const BackButton(),
        title: 'Write a Near Miss',
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeadingTitleWidget(
                title: 'Add images',
              ),

              const SizedBox(
                height: 10,
              ),

              // near miss images
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        AddImage(onTap: () async {
                          // showImagePickerDialog(context);
                        }),
                        for (var image in nearMissProvider.nearMiss!.images)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: MyImageCacheManager.showImage(
                                        imageUrl: image,
                                        isTool: false,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              // assessment description field
              InputField(
                labelText: Constants.enterDescription,
                hintText: Constants.enterDescription,
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
