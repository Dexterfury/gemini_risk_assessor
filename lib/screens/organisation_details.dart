import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/streams/members_card.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_org_image.dart';
import 'package:gemini_risk_assessor/widgets/exit_organisation_card.dart';
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

  void showLoadingDialog() {
    if (mounted) {
      MyDialogs.showMyAnimatedDialog(
        context: context,
        title: 'Saving',
        content: 'Please wait...',
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
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    bool isAdmin = widget.orgModel.adminsUIDs.contains(uid);
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
              buildMembersList(isAdmin, uid)
            ],
          ),
        ),
      ),
    );
  }

  Column buildMembersList(bool isAdmin, String uid) {
    return Column(
      children: [
        MembersCard(
          orgModel: widget.orgModel,
          isAdmin: isAdmin,
        ),
        const SizedBox(height: 10),
        ExitGroupCard(
          uid: uid,
        )
      ],
    );
  }

  Row buildAddMembers(String membersCount, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          membersCount,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const People(),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
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
                      showLoadingDialog();

                      await FileUploadHandler.updateImage(
                        file: file,
                        isUser: false,
                        id: widget.orgModel.organisationID,
                        reference:
                            '${Constants.organisationImage}/${widget.orgModel.organisationID}.jpg',
                      );

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

  String getMembersCount(
    OrganisationModel orgModel,
  ) {
    if (orgModel.membersUIDs.isEmpty) {
      return 'No members';
    } else if (orgModel.membersUIDs.length == 1) {
      return '1 member';
    } else {
      return '${orgModel.membersUIDs.length} members';
    }
  }
}
