import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/buttons_row.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/fab_buttons/my_fab_button.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/org_settings_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/members_card.dart';
import 'package:gemini_risk_assessor/screens/organization_settings_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_org_image.dart';
import 'package:gemini_risk_assessor/widgets/exit_organisation_card.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class OrganizationDetails extends StatefulWidget {
  const OrganizationDetails({
    super.key,
    required this.orgModel,
  });

  final OrganizationModel orgModel;

  @override
  State<OrganizationDetails> createState() => _OrganizationDetailsState();
}

class _OrganizationDetailsState extends State<OrganizationDetails>
    with SingleTickerProviderStateMixin {
  File? _finalFileImage;
  bool _hasReadTerms = false;

  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showLoadingDialog({
    required String title,
  }) {
    if (mounted) {
      MyDialogs.showMyAnimatedDialog(
          context: context,
          title: title,
          loadingIndicator: const SizedBox(
            height: 100,
            width: 100,
            child: LoadingPPEIcons(),
          ));
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );
    _animation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    setOrgModel();

    super.initState();
  }

  void setOrgModel() async {
    // wait for widget  to be built before setting state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<OrganizationProvider>()
          .setOrganizationModel(orgModel: widget.orgModel);
    });
  }

  // set new image from file and update provider
  Future<void> setNewImageInProvider(String imageUrl) async {
    // set newimage in provider
    await context.read<OrganizationProvider>().setImageUrl(imageUrl);
  }

  // set new name  in provider
  Future<void> setNewNameInProvider(String newName) async {
    // set new name in provider
    await context.read<OrganizationProvider>().setName(newName);
  }

  // set new description in provider
  Future<void> setNewDescriptionInProvider(String newDescription) async {
    // set new description in provider
    await context.read<OrganizationProvider>().setDescription(newDescription);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    bool isAdmin = widget.orgModel.adminsUIDs.contains(uid);
    String orgID = widget.orgModel.organizationID;
    String membersCount = getMembersCount(widget.orgModel);
    bool showAcceptBtn = widget.orgModel.awaitingApprovalUIDs.contains(uid);
    return Scaffold(
      appBar: MyAppBar(
        title: 'Organisation Details',
        leading: const BackButton(),
        actions: [
          isAdmin
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                      onPressed: () async {
                        context
                            .read<OrgSettingsProvider>()
                            .setOrganizationModel(widget.orgModel)
                            .whenComplete(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const OrganizationSettingsScreen(),
                            ),
                          );
                        });
                      },
                      icon: const Icon(FontAwesomeIcons.gear, size: 20)),
                )
              : const SizedBox(),
        ],
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
                      buildImageAndName(
                        isAdmin,
                        context,
                        showAcceptBtn,
                        widget.orgModel,
                        uid,
                      ),

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
              ButtonsRow(
                orgID: orgID,
                isAdmin: isAdmin,
              ),

              const SizedBox(height: 10),

              // members list if the user is an admin
              buildMembersList(
                isAdmin,
                uid,
                orgID,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: MyFabButton(
        animationController: _animationController,
        animation: _animation,
        organisationID: widget.orgModel.organizationID,
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
        // members list
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
                    );
                    final orgProvider = context.read<OrganizationProvider>();

                    String result = await orgProvider.exitOrganization(
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

  // Row buildButtonsRow(
  //   String orgID,
  // ) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       _buildIconButton(Icons.assignment_add, orgID),
  //       _buildIconButton(Icons.assignment_late_outlined, orgID),
  //       _buildIconButton(Icons.handyman, orgID),
  //     ],
  //   );
  // }

  // Widget _buildIconButton(
  //   IconData icon,
  //   String orgID,
  // ) {
  //   return OpenContainer(
  //     closedColor: Theme.of(context).colorScheme.primary,
  //     closedBuilder: (context, action) {
  //       return IconButton(
  //         onPressed: () async {
  //           // set search data depending on the clicked icon
  //           await _setSearchData(context, icon);
  //           action();
  //         },
  //         icon: Icon(
  //           icon,
  //           color: Colors.white,
  //         ),
  //       );
  //     },
  //     openBuilder: (context, action) {
  //       // navigate to screen depending on the clicked icon
  //       return _navigateToScreen(icon, orgID);
  //     },
  //     transitionType: ContainerTransitionType.fadeThrough,
  //     transitionDuration: const Duration(milliseconds: 500),
  //     closedShape:
  //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     closedElevation: 4,
  //     openElevation: 4,
  //   );
  // }

  // Widget _buildMembersSection(String membersCount, BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {

  //     },
  //     child: const IconContainer(
  //       containerColor: Colors.blue,
  //       icon: Icons.person_add,
  //       padding: 12,
  //       borderRadius: 4.0,
  //     ),
  //   );
  // }

  void _showPeopleDialog({
    required BuildContext context,
    required Function(bool) onActionTap,
  }) {
    MyDialogs.showAnimatedPeopleDialog(
        context: context,
        userViewType: UserViewType.tempPlus,
        actions: [
          TextButton(
            onPressed: () {
              onActionTap(false);
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: textStyle18Bold,
            ),
          ),
          TextButton(
            onPressed: () {
              onActionTap(true);
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: textStyle18Bold,
            ),
          ),
        ]);
  }

  Column buildDescription(bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                          hintText: widget.orgModel.aboutOrganization,
                          textAction: "Change",
                          onActionTap: (value, updatedText) async {
                            if (value) {
                              final authProvider = context.read<AuthProvider>();
                              final desc = await authProvider.updateDescription(
                                isUser: false,
                                id: widget.orgModel.organizationID,
                                newDesc: updatedText,
                                oldDesc: widget.orgModel.aboutOrganization,
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
          widget.orgModel.aboutOrganization,
          style: textStyle16w600,
        ),
      ],
    );
  }

  buildImageAndName(
    bool isAdmin,
    BuildContext context,
    bool showAcceptBtn,
    OrganizationModel orgModel,
    String uid,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      });
                      // show loading dialog
                      showLoadingDialog(
                        title: 'Saving,',
                      );

                      final imageUrl = await FileUploadHandler.updateImage(
                        file: file,
                        isUser: false,
                        id: widget.orgModel.organizationID,
                        reference:
                            '${Constants.organizationImage}/${widget.orgModel.organizationID}.jpg',
                      );

                      // set newimage in provider
                      await setNewImageInProvider(imageUrl);

                      // pop loading dialog
                      popDialog();
                    }
                  },
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.orgModel.name,
                        style: textStyle18Bold,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    if (isAdmin)
                      GestureDetector(
                        onTap: () {
                          // edit org name
                          MyDialogs.showMyEditAnimatedDialog(
                            context: context,
                            title: 'Edit Name',
                            content: Constants.changeName,
                            hintText: widget.orgModel.name,
                            textAction: "Change",
                            onActionTap: (value, updatedText) async {
                              if (value) {
                                final authProvider =
                                    context.read<AuthProvider>();
                                final name = await authProvider.updateName(
                                  isUser: false,
                                  id: widget.orgModel.organizationID,
                                  newName: updatedText,
                                  oldName: widget.orgModel.name,
                                );
                                if (name == 'Invalid name.') return;
                                // set new name
                                await setNewNameInProvider(name);
                                Future.delayed(
                                        const Duration(milliseconds: 200))
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
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                isAdmin
                    ? MainAppButton(
                        icon: Icons.person_add,
                        label: 'People',
                        contanerColor: Colors.blue,
                        onTap: () {
                          // show people dialog
                          _showPeopleDialog(
                              context: context,
                              onActionTap: (value) async {
                                if (value) {
                                  bool isSaved = await context
                                      .read<OrganizationProvider>()
                                      .updateOrganizationDataInFireStore();

                                  if (isSaved) {
                                    Future.delayed(
                                            const Duration(milliseconds: 100))
                                        .whenComplete(() {
                                      showSnackBar(
                                        context: context,
                                        message:
                                            'Requests sent to added members',
                                      );
                                    });
                                  }
                                }

                                Future.delayed(
                                        const Duration(milliseconds: 100))
                                    .whenComplete(() async {
                                  // clear search query
                                  context
                                      .read<OrganizationProvider>()
                                      .setSearchQuery('');
                                });
                              });
                        },
                      )
                    : const SizedBox.shrink(),
                showAcceptBtn
                    ? MainAppButton(
                        icon: Icons.person_add,
                        label: 'Accept Invite',
                        contanerColor: Colors.orangeAccent,
                        onTap: () {
                          // accept invite
                          // first check if admin set to read terms and conditions
                          if (orgModel.requestToReadTerms) {
                            if (!_hasReadTerms) {
                              MyDialogs.animatedTermsDialog(
                                  context: context,
                                  title: "Terms and Conditions",
                                  content: orgModel.organizationTerms,
                                  isMember: orgModel.membersUIDs.contains(uid),
                                  onAccept: () {
                                    // Handle acceptance here
                                    // join org and update data in firestore
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    setState(() {
                                      _hasReadTerms = true;
                                    });
                                    // update user data in firestore to add to members list and update role to member
                                  },
                                  onDecline: () {
                                    // Handle decline here
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  });
                            }
                          } else {
                            // join org and update data in firestore
                          }
                        },
                      )
                    : Container(),
                orgModel.organizationTerms.isNotEmpty
                    ? TextButton(
                        onPressed: () {
                          // show terms and conditions dialog
                          MyDialogs.animatedTermsDialog(
                              context: context,
                              title: "Terms and Conditions",
                              content: orgModel.organizationTerms,
                              isMember: orgModel.membersUIDs.contains(uid),
                              onAccept: () {
                                // Handle acceptance here
                                Navigator.of(context).pop(); // Close the dialog
                                setState(() {
                                  _hasReadTerms = true;
                                });
                              },
                              onDecline: () {
                                // Handle decline here
                                Navigator.of(context).pop(); // Close the dialog
                              });
                        },
                        child: const Text('Terms'),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          )
        ],
      ),
    );
  }

  //  get member count function
  String getMembersCount(OrganizationModel orgModel) {
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
