import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_org_image.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class CreateOrganizationScreen extends StatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  State<CreateOrganizationScreen> createState() =>
      _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends State<CreateOrganizationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _termsController = TextEditingController();

  File? _finalFileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final organizationProvider = context.watch<OrganizationProvider>();
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Create Organization',
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20.0,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DisplayOrgImage(
                    fileImage: _finalFileImage,
                    onPressed: () async {
                      final file =
                          await ImagePickerHandler.showImagePickerDialog(
                        context: context,
                      );
                      if (file != null) {
                        setState(() {
                          _finalFileImage = file;
                        });
                      }
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MainAppButton(
                    icon: Icons.person_add,
                    label: 'People',
                    onTap: () {
                      if (organizationProvider.isLoading) {
                        return;
                      }

                      MyDialogs.showAnimatedPeopleDialog(
                        context: context,
                        userViewType: UserViewType.creator,
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                                style: textStyle18Bold,
                              ))
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // organization name input field
              InputField(
                labelText: Constants.organizationName,
                hintText: Constants.organizationName,
                controller: _nameController,
                organizationProvider: organizationProvider,
              ),

              const SizedBox(height: 20),
              // organization description input field
              InputField(
                labelText: Constants.enterDescription,
                hintText: Constants.enterDescription,
                controller: _descriptionController,
                organizationProvider: organizationProvider,
              ),

              const SizedBox(height: 20),
              // organization description input field
              InputField(
                labelText: Constants.enterTerms,
                hintText: Constants.termsOptional,
                controller: _termsController,
                organizationProvider: organizationProvider,
              ),

              const SizedBox(height: 40),

              MainAppButton(
                icon: Icons.save,
                label: 'Save and Continue',
                onTap: () {
                  if (organizationProvider.isLoading) {
                    return;
                  }
                  // check name
                  final emptyName = _nameController.text.isEmpty;
                  final shortName = _nameController.text.length < 3;

                  // check description
                  final emptyDescription = _descriptionController.text.isEmpty;
                  final shortDescription =
                      _descriptionController.text.length < 10;

                  // if terms controller is not null, check terms length, it shpuld not be less than 10
                  final invalidTerms = _termsController.text.isNotEmpty &&
                      _termsController.text.length < 10;
                  if (invalidTerms) {
                    showSnackBar(
                      context: context,
                      message:
                          'Terms field must be empty or atleast atleast 10 Characters',
                    );
                    return;
                  }

                  // check name
                  if (emptyName || shortName) {
                    showSnackBar(
                      context: context,
                      message: emptyName
                          ? 'Please enter organization name'
                          : 'organization name must be at least 3 characters',
                    );
                    return;
                  }
                  // check description
                  if (emptyDescription || shortDescription) {
                    showSnackBar(
                      context: context,
                      message: emptyDescription
                          ? 'Please enter organization description'
                          : 'organization description must be at least 10 characters',
                    );
                    return;
                  }

                  final orgModel = OrganizationModel(
                    creatorUID: context.read<AuthProvider>().userModel!.uid,
                    name: _nameController.text,
                    aboutOrganization: _descriptionController.text,
                    organizationTerms: _termsController.text,
                    imageUrl: '',
                  );

                  // show loading dialog
                  // show my alert dialog for loading
                  MyDialogs.showMyAnimatedDialog(
                    context: context,
                    title: 'Creating organization',
                    loadingIndicator: const SizedBox(
                      height: 100,
                      width: 100,
                      child: LoadingPPEIcons(),
                    ),
                  );

                  // save organization data to firestore
                  organizationProvider.createOrganization(
                    fileImage: _finalFileImage,
                    newOrganizationModel: orgModel,
                    onSuccess: () {
                      // pop the loading dialog
                      Navigator.pop(context);
                      // clear data
                      setState(() {
                        _nameController.text = '';
                        _descriptionController.text = '';
                        _finalFileImage = null;
                      });
                      showSnackBar(
                          context: context, message: 'Organization created');
                      // pop to previous screen
                      Navigator.pop(context);
                    },
                    onError: (error) {
                      // pop the loading dialog
                      Navigator.pop(context);
                      showSnackBar(context: context, message: error.toString());
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
