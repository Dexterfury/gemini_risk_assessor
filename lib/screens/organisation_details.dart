import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/organisation_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/streams/members_card.dart';
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
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Organisation Details',
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DisplayOrgImage(
                      isViewOnly: true,
                      fileImage: _finalFileImage,
                      imageUrl: widget.orgModel.imageUrl!,
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
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(widget.orgModel.organisationName)
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // organisation name input field
              Text(
                widget.orgModel.aboutOrganisation,
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Add Members',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add),
                    ),
                  )
                ],
              ),

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
}
