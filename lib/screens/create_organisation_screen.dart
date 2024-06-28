import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/input_field.dart';
import 'package:gemini_risk_assessor/widgets/main_app_button.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class CreateOrganisationScreen extends StatefulWidget {
  const CreateOrganisationScreen({super.key});

  @override
  State<CreateOrganisationScreen> createState() =>
      _CreateOrganisationScreenState();
}

class _CreateOrganisationScreenState extends State<CreateOrganisationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // void showBottomSheet() {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         return const OrganisationBottomSheet();
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    final organisationProvider = context.watch<OrganisationProvider>();
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Create Organisation',
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DisplayUserImage(
                        radius: 50,
                        isViewOnly: false,
                        organisationProvider: organisationProvider,
                        onPressed: () {
                          // authProvider.showImagePickerDialog(
                          //   context: context,
                          // );
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      MainAppButton(
                        widget: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                        ),
                        label: 'Add People',
                        onTap: () {
                          if (organisationProvider.isLoading) {
                            return;
                          }

                          // show botton sheet
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // organisation name input field
              InputField(
                labelText: Constants.organisationName,
                hintText: Constants.organisationName,
                controller: _nameController,
                organisationProvider: organisationProvider,
              ),

              const SizedBox(height: 20),
              // organisation description input field
              InputField(
                labelText: Constants.enterDescription,
                hintText: Constants.enterDescription,
                controller: _descriptionController,
                organisationProvider: organisationProvider,
              ),

              const SizedBox(height: 40),

              MainAppButton(
                widget: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                label: 'Save and Continue',
                onTap: () {
                  if (organisationProvider.isLoading) {
                    return;
                  }
                  // check name
                  final emptyName = _nameController.text.isEmpty;
                  final shortName = _nameController.text.length < 3;

                  // check description
                  final emptyDescription = _descriptionController.text.isEmpty;
                  final shortDescription =
                      _descriptionController.text.length < 10;

                  // check name
                  if (emptyName || shortName) {
                    showSnackBar(
                      context: context,
                      message: emptyName
                          ? 'Please enter organisation name'
                          : 'organisation name must be at least 3 characters',
                    );
                    return;
                  }
                  // check description
                  if (emptyDescription || shortDescription) {
                    showSnackBar(
                      context: context,
                      message: emptyDescription
                          ? 'Please enter organisation description'
                          : 'organisation description must be at least 10 characters',
                    );
                    return;
                  }

                  // save organisation data to firestore
                },
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
