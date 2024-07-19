import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/screens/organization_settings_screen.dart';
import 'package:gemini_risk_assessor/screens/people_screen.dart';
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

  File? _finalFileImage;
  DataSettings _dataSettings = DataSettings();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final organizationProvider = context.watch<OrganizationProvider>();
    final selectedCount = getMembersCount(organizationProvider);
    return Scaffold(
      appBar: MyAppBar(
        title: 'Create Organization',
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrganizationSettingsScreen(
                    isNew: true,
                    initialSettings: DataSettings(
                      requestToReadTerms: _dataSettings.requestToReadTerms,
                      allowSharing: _dataSettings.allowSharing,
                      organizationTerms: _dataSettings.organizationTerms,
                    ),
                    onSave: (DataSettings settings) {
                      setState(() {
                        _dataSettings = settings;
                      });
                    },
                  ),
                ),
              );
            },
            icon: const Icon(
              FontAwesomeIcons.gear,
            ),
          ),
        ],
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DisplayOrgImage(
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
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCount,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        OpenContainer(
                          closedBuilder: (context, action) {
                            return IconButton(
                              onPressed: () {
                                if (organizationProvider.isLoading) {
                                  return;
                                }

                                action();
                              },
                              icon: const Icon(
                                FontAwesomeIcons.userPlus,
                              ),
                            );
                          },
                          openBuilder: (context, action) {
                            // navigate to people screen
                            return const PeopleScreen(
                              userViewType: UserViewType.creator,
                            );
                          },
                          transitionType: ContainerTransitionType.fadeThrough,
                          transitionDuration: const Duration(milliseconds: 500),
                          closedElevation: cardElevation,
                          openElevation: 4,
                        ),
                      ],
                    ),
                  ],
                ),
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

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: MainAppButton(
                  label: ' Create Organization ',
                  borderRadius: 15,
                  onTap: () {
                    if (organizationProvider.isLoading) {
                      return;
                    }
                    // check name
                    final emptyName = _nameController.text.isEmpty;
                    final shortName = _nameController.text.length < 3;

                    // check description
                    // final emptyDescription = _descriptionController.text.isEmpty;
                    // final shortDescription =
                    //     _descriptionController.text.length < 10;
                    // final desc = emptyDescription ? Constants.defaultDescription : _descriptionController.text;

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
                    // if (emptyDescription || shortDescription) {
                    //   showSnackBar(
                    //     context: context,
                    //     message: emptyDescription
                    //         ? 'Please enter organization description'
                    //         : 'organization description must be at least 10 characters',
                    //   );
                    //   return;
                    // }

                    final orgModel = OrganizationModel(
                      creatorUID:
                          context.read<AuthenticationProvider>().userModel!.uid,
                      name: _nameController.text,
                      aboutOrganization: _descriptionController.text,
                      imageUrl: '',
                      organizationTerms: _dataSettings.organizationTerms,
                      requestToReadTerms: _dataSettings.requestToReadTerms,
                      allowSharing: _dataSettings.allowSharing,
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
                        showSnackBar(
                            context: context, message: error.toString());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
