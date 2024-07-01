import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/streams/members_card.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_org_image.dart';
import 'package:gemini_risk_assessor/widgets/exit_organisation_card.dart';
import 'package:gemini_risk_assessor/widgets/icon_container.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/people.dart';
import 'package:provider/provider.dart';

class OrganisationDetails extends StatefulWidget {
  const OrganisationDetails({
    super.key,
    required this.orgModel,
  });

  final OrganisationModel orgModel;

  @override
  State<OrganisationDetails> createState() => _OrganisationDetailsState();
}

class _OrganisationDetailsState extends State<OrganisationDetails> {
  File? _finalFileImage;

  void showLoadingDialog({
    required String title,
    required String message,
  }) {
    if (mounted) {
      MyDialogs.showMyAnimatedDialog(
        context: context,
        title: title,
        content: message,
        loadingIndicator: const SizedBox(
            height: 40, width: 40, child: CircularProgressIndicator()),
      );
    }
  }

  void popDialog() {
    if (mounted) {
      Navigator.pop(context);
      // show snack bar
      showSnackBar(context: context, message: 'Successfully changed image');
    }
  }

  @override
  void initState() {
    setOrgModel();
    super.initState();
  }

  void setOrgModel() async {
    // wait for widget  to be built before setting state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OrganisationProvider>()
          .setOrganisationModel(orgModel: widget.orgModel);
    });
  }

  // set new image from file and update provider
  Future<void> setNewImageInProvider(String imageUrl) async {
    // set newimage in provider
    await context.read<OrganisationProvider>().setImageUrl(imageUrl);
  }

  // set new name  in provider
  Future<void> setNewNameInProvider(String newName) async {
    // set new name in provider
    await context.read<OrganisationProvider>().setName(newName);
  }

  // set new description in provider
  Future<void> setNewDescriptionInProvider(String newDescription) async {
    // set new description in provider
    await context.read<OrganisationProvider>().setDescription(newDescription);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    bool isAdmin = widget.orgModel.adminsUIDs.contains(uid);
    String orgID = widget.orgModel.organisationID;
    String membersCount = getMembersCount(widget.orgModel);
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Organisation Details',
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      //  organisation name and image
                      buildImageAndName(isAdmin, context),

                      const SizedBox(height: 10),

                      // divider
                      const Divider(
                        thickness: 1,
                        color: Colors.black26,
                      ),

                      //  organisation description
                      buildDescription(isAdmin),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //  add members button if the user is an admin
              buildAddMembers(membersCount, context),

              const SizedBox(height: 10),

              //   members list if the user is an admin
              buildMembersList(
                isAdmin,
                uid,
                orgID,
              )
            ],
          ),
        ),
      ),
    );
  }

  Column buildMembersList(
    bool isAdmin,
    String uid,
    String orgID,
  ) {
    return Column(
      children: [
        MembersCard(
          orgModel: widget.orgModel,
          isAdmin: isAdmin,
        ),
        const SizedBox(height: 10),
        ExitCard(
          onTap: () {
            // exit group
            MyDialogs.showMyAnimatedDialog(
              context: context,
              title: 'Exit Group',
              content: 'Are you sure you want to exit the group?',
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // pop the dialog
                    Navigator.pop(context);

                    // show loading dialog
                    showLoadingDialog(
                      title: 'Exiting',
                      message: 'Please wait...',
                    );
                    final orgProvider = context.read<OrganisationProvider>();

                    String result = await orgProvider.exitOrganisation(
                      isAdmin: isAdmin,
                      uid: uid,
                      orgID: orgID,
                    );

                    if (result == Constants.exitSuccessful ||
                        result == Constants.deletedSuccessfully) {
                      Future.delayed(const Duration(milliseconds: 200))
                          .whenComplete(() {
                        if (context.mounted) {
                          // pop loading dialog
                          Navigator.pop(context);
                          // show snackbar
                          showSnackBar(
                            context: context,
                            message: result,
                          );
                          // pop the Organization details Screen
                          Navigator.pop(context);
                        }
                      });
                    } else {
                      Future.delayed(const Duration(milliseconds: 200))
                          .whenComplete(() {
                        if (context.mounted) {
                          // pop loading dialog
                          Navigator.pop(context);
                          // show snackbar
                          showSnackBar(
                            context: context,
                            message: result,
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        )
      ],
    );
  }

  Row buildAddMembers(String membersCount, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconButton(Icons.assignment_add),
        _buildIconButton(Icons.assignment_late_outlined),
        _buildIconButton(Icons.handyman),
        _buildMembersSection(membersCount, context),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(icon),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildMembersSection(String membersCount, BuildContext context) {
    return Row(
      children: [
        Text(
          membersCount,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () => _showPeopleDialog(context),
          child: const IconContainer(icon: Icons.person_add),
        ),
      ],
    );
  }

  void _showPeopleDialog(BuildContext context) {
    MyDialogs.showAnimatedPeopleDialog(
        context: context,
        userViewType: UserViewType.tempPlus,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: textStyle18Bold,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Save',
              style: textStyle18Bold,
            ),
          ),
        ]);
  }

  Column buildDescription(bool isAdmin) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'About Us',
              style: textStyle18Bold,
            ),
            isAdmin
                ? Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // edit org description
                        // edit org name
                        MyDialogs.showMyEditAnimatedDialog(
                          context: context,
                          title: 'Edit Description',
                          content: Constants.changeDescription,
                          hintText: widget.orgModel.aboutOrganisation,
                          textAction: "Change",
                          onActionTap: (value, updatedText) async {
                            if (value) {
                              final authProvider = context.read<AuthProvider>();
                              final desc = await authProvider.updateDescription(
                                isUser: false,
                                id: widget.orgModel.organisationID,
                                newDesc: updatedText,
                                oldDesc: widget.orgModel.aboutOrganisation,
                              );
                              if (desc == 'Invalid description.') return;
                              await setNewDescriptionInProvider(desc);
                              Future.delayed(const Duration(milliseconds: 200))
                                  .whenComplete(() {
                                showSnackBar(
                                    context: context,
                                    message: 'Change successful');
                              });
                            }
                          },
                        );
                      },
                      child: const Icon(
                        Icons.edit,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          widget.orgModel.aboutOrganisation,
          style: textStyle18w500,
        ),
      ],
    );
  }

  Row buildImageAndName(bool isAdmin, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DisplayOrgImage(
          isViewOnly: true,
          fileImage: _finalFileImage,
          imageUrl: widget.orgModel.imageUrl!,
          onPressed: !isAdmin
              ? null
              : () async {
                  final file = await ImagePickerHandler.showImagePickerDialog(
                    context: context,
                  );
                  if (file != null) {
                    setState(() async {
                      _finalFileImage = file;

                      // show loading dialog
                      showLoadingDialog(
                        title: 'Saving,',
                        message: 'Please wait...',
                      );

                      final imageUrl = await FileUploadHandler.updateImage(
                        file: file,
                        isUser: false,
                        id: widget.orgModel.organisationID,
                        reference:
                            '${Constants.organisationImage}/${widget.orgModel.organisationID}.jpg',
                      );

                      // set newimage in provider
                      await setNewImageInProvider(imageUrl);

                      // pop loading dialog
                      popDialog();
                    });
                  }
                },
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            isAdmin
                ? GestureDetector(
                    onTap: () {
                      // edit org name
                      MyDialogs.showMyEditAnimatedDialog(
                        context: context,
                        title: 'Edit Name',
                        content: Constants.changeName,
                        hintText: widget.orgModel.organisationName,
                        textAction: "Change",
                        onActionTap: (value, updatedText) async {
                          if (value) {
                            final authProvider = context.read<AuthProvider>();
                            final name = await authProvider.updateName(
                              isUser: false,
                              id: widget.orgModel.organisationID,
                              newName: updatedText,
                              oldName: widget.orgModel.organisationName,
                            );
                            if (name == 'Invalid name.') return;
                            // set new name
                            await setNewNameInProvider(name);
                            Future.delayed(const Duration(milliseconds: 200))
                                .whenComplete(() {
                              showSnackBar(
                                  context: context,
                                  message: 'Change successful');
                            });
                          }
                        },
                      );
                    },
                    child: const Icon(
                      Icons.edit,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 10),
            Text(
              widget.orgModel.organisationName,
              style: textStyle18w500,
            )
          ],
        )
      ],
    );
  }

  //  get member count function
  String getMembersCount(OrganisationModel orgModel) {
    int count = orgModel.membersUIDs.length;

    if (count == 0) {
      return '';
    } else if (count == 1) {
      return '1';
    } else if (count < 100) {
      return count.toString();
    } else if (count < 1000) {
      return '$count+';
    } else if (count < 1000000) {
      return '${(count / 1000).floor()}k+';
    } else {
      return '${(count / 1000000).floor()}M+';
    }
  }
}
