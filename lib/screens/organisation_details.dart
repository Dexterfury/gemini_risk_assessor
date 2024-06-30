import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/streams/members_card.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_org_image.dart';
import 'package:gemini_risk_assessor/widgets/exit_organisation_card.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DisplayOrgImage(
                            isViewOnly: true,
                            fileImage: _finalFileImage,
                            imageUrl: widget.orgModel.imageUrl!,
                            onPressed: () async {
                              final file = await ImagePickerHandler
                                  .showImagePickerDialog(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.edit,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.orgModel.organisationName,
                                style: textStyle18w500,
                              )
                            ],
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      // divider
                      const Divider(
                        thickness: 1,
                        color: Colors.black26,
                      ),

                      // organisation name input field
                      Text(
                        widget.orgModel.aboutOrganisation,
                        style: textStyle18w500,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
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
                      onPressed: () {},
                      icon: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  MembersCard(
                    orgID: widget.orgModel.organisationID,
                    isAdmin: widget.orgModel.adminsUIDs.contains(uid),
                  ),
                  const SizedBox(height: 10),
                  ExitGroupCard(
                    uid: uid,
                  )
                ],
              )
            ],
          ),
        ),
      ),
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
