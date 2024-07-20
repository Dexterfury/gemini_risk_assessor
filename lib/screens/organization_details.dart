import 'dart:io';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/buttons_row.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/fab_buttons/my_fab_button.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/models/organization_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/members_card.dart';
import 'package:gemini_risk_assessor/screens/organization_settings_screen.dart';
import 'package:gemini_risk_assessor/screens/people_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_org_image.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/settings_list_tile.dart';
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
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Consumer<OrganizationProvider>(
        builder: (context, orgProvider, child) {
      bool isAdmin = orgProvider.organizationModel.adminsUIDs.contains(uid);
      bool isMember = orgProvider.organizationModel.membersUIDs.contains(uid);
      String orgID = orgProvider.organizationModel.organizationID;
      String orgTerms = orgProvider.organizationModel.organizationTerms;
      bool requestToReadTerms =
          orgProvider.organizationModel.requestToReadTerms;
      bool allowSharing = orgProvider.organizationModel.allowSharing;

      //String membersCount = getMembersCount(orgProvider.organizationModel);
      bool showAcceptBtn =
          orgProvider.organizationModel.awaitingApprovalUIDs.contains(uid);
      return Scaffold(
        appBar: MyAppBar(
          title: 'Organisation Details',
          leading: const BackButton(),
          actions: [
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrganizationSettingsScreen(
                          isNew: false,
                          initialSettings: DataSettings(
                            requestToReadTerms: requestToReadTerms,
                            allowSharing: allowSharing,
                            organizationTerms: orgTerms,
                          ),
                          onSave: (DataSettings settings) {
                            orgProvider.updateOrganizationSettings(settings);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.gear, size: 20),
                ),
              )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  color: Theme.of(context).cardColor,
                  elevation: cardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        //  organisation name and image
                        buildImageAndName(
                          isAdmin,
                          context,
                          showAcceptBtn,
                          orgProvider,
                          uid,
                        ),

                        const SizedBox(height: 10),

                        // divider
                        const Divider(
                          thickness: 1,
                          color: Colors.black26,
                        ),

                        //  organisation description
                        buildDescription(
                          isAdmin,
                          orgProvider,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                //  add members button if the user is an admin
                ButtonsRow(
                  orgID: orgID,
                  isAdmin: isAdmin,
                  isMember: isMember,
                ),

                const SizedBox(height: 10),

                // members list if the user is an admin
                buildMembersList(
                  isAdmin,
                  uid,
                  orgID,
                  orgProvider,
                )
              ],
            ),
          ),
        ),
        floatingActionButton: MyFabButton(
          animationController: _animationController,
          animation: _animation,
          organisationID: orgProvider.organizationModel.organizationID,
        ),
      );
    });
  }

  Column buildMembersList(
    bool isAdmin,
    String uid,
    String orgID,
    OrganizationProvider orgProvider,
  ) {
    return Column(
      children: [
        // members list
        MembersCard(
          orgModel: orgProvider.organizationModel,
          isAdmin: isAdmin,
        ),
        const SizedBox(height: 20),

        Card(
          color: Theme.of(context).cardColor,
          elevation: cardElevation,
          child: SettingsListTile(
            title: 'Exit Organization',
            icon: FontAwesomeIcons.arrowRightFromBracket,
            iconContainerColor: Colors.red,
            onTap: () {
              // exit group
              MyDialogs.showMyAnimatedDialog(
                context: context,
                title: 'Exit Organization',
                content: 'Are you sure you want to leave this Organisation?',
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // pop the dialog
                      Navigator.pop(context);

                      // show loading dialog
                      showLoadingDialog(
                        title: 'Exiting',
                      );

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
          ),
        )
      ],
    );
  }

  Column buildDescription(
    bool isAdmin,
    OrganizationProvider orgProvider,
  ) {
    final desc = orgProvider.organizationModel.aboutOrganization;
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
                          maxLength: 500,
                          hintText:
                              orgProvider.organizationModel.aboutOrganization,
                          textAction: "Change",
                          onActionTap: (value, updatedText) async {
                            if (value) {
                              final authProvider =
                                  context.read<AuthenticationProvider>();
                              final desc = await authProvider.updateDescription(
                                isUser: false,
                                id: orgProvider
                                    .organizationModel.organizationID,
                                newDesc: updatedText,
                                oldDesc: orgProvider
                                    .organizationModel.aboutOrganization,
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
        desc.isEmpty
            ? const SizedBox.shrink()
            : AnimatedReadMoreText(
                desc,
                maxLines: 3,
                // Set a custom text style for the main block of text
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
                // Set a custom text style for the expand/collapse button
                buttonTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }

  buildImageAndName(
    bool isAdmin,
    BuildContext context,
    bool showAcceptBtn,
    OrganizationProvider orgProvider,
    String uid,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DisplayOrgImage(
              isViewOnly: true,
              fileImage: _finalFileImage,
              imageUrl: orgProvider.organizationModel.imageUrl ?? '',
              onPressed: !isAdmin
                  ? null
                  : () async {
                      final file =
                          await ImagePickerHandler.showImagePickerDialog(
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
                          id: orgProvider.organizationModel.organizationID,
                          reference:
                              '${Constants.organizationImage}/${orgProvider.organizationModel.organizationID}.jpg',
                        );

                        // set newimage in provider
                        await setNewImageInProvider(imageUrl);

                        // pop loading dialog
                        popDialog();
                      }
                    },
            ),
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
                        orgProvider.organizationModel.name,
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
                            hintText: orgProvider.organizationModel.name,
                            textAction: "Change",
                            onActionTap: (value, updatedText) async {
                              if (value) {
                                final authProvider =
                                    context.read<AuthenticationProvider>();
                                final name = await authProvider.updateName(
                                  isUser: false,
                                  id: orgProvider
                                      .organizationModel.organizationID,
                                  newName: updatedText,
                                  oldName: orgProvider.organizationModel.name,
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
                if (isAdmin)
                  OpenContainer(
                    closedBuilder: (context, action) {
                      return IconButton(
                        onPressed: action,
                        icon: const Icon(
                          FontAwesomeIcons.userPlus,
                        ),
                      );
                    },
                    openBuilder: (context, action) {
                      // navigate to people screen
                      return const PeopleScreen(
                        userViewType: UserViewType.tempPlus,
                      );
                    },
                    transitionType: ContainerTransitionType.fadeThrough,
                    transitionDuration: const Duration(milliseconds: 500),
                    closedElevation: cardElevation,
                    openElevation: 4,
                  ),
                // Card(
                //   color: Theme.of(context).cardColor,
                //   elevation: cardElevation,
                //   shape: const CircleBorder(),
                //   child: IconButton(
                //     onPressed: () {
                //       // show people dialog
                //       _showPeopleDialog(
                //           context: context,
                //           onActionTap: (value) async {
                //             if (value) {
                //               bool isSaved = await context
                //                   .read<OrganizationProvider>()
                //                   .updateOrganizationDataInFireStore();

                //               if (isSaved) {
                //                 Future.delayed(
                //                         const Duration(milliseconds: 100))
                //                     .whenComplete(() {
                //                   showSnackBar(
                //                     context: context,
                //                     message: 'Requests sent to added members',
                //                   );
                //                 });
                //               }
                //             }

                //             Future.delayed(const Duration(milliseconds: 100))
                //                 .whenComplete(() async {
                //               // clear search query
                //               context
                //                   .read<OrganizationProvider>()
                //                   .setSearchQuery('');
                //             });
                //           });
                //     },
                //     icon: const Icon(
                //       FontAwesomeIcons.userPlus,
                //     ),
                //   ),
                // ),
                if (showAcceptBtn)
                  orgProvider.isLoading
                      ? const CircularProgressIndicator()
                      : MainAppButton(
                          icon: Icons.person_add,
                          label: 'Accept Invite',
                          contanerColor: Colors.orangeAccent,
                          onTap: () async {
                            // accept invite
                            // first check if admin set to read terms and conditions
                            if (orgProvider
                                .organizationModel.requestToReadTerms) {
                              if (!_hasReadTerms) {
                                MyDialogs.animatedTermsDialog(
                                    context: context,
                                    title: "Terms and Conditions",
                                    content: orgProvider
                                        .organizationModel.organizationTerms,
                                    isMember: orgProvider
                                        .organizationModel.membersUIDs
                                        .contains(uid),
                                    onAccept: () {
                                      // Handle acceptance here
                                      // join org and update data in firestore
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                      setState(() {
                                        _hasReadTerms = true;
                                      });
                                    },
                                    onDecline: () {
                                      // Handle decline here
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    });
                              } else {
                                // join org and update data in firestore
                                await orgProvider
                                    .addMemberToOrganization(
                                  uid: uid,
                                )
                                    .whenComplete(() {
                                  showSnackBar(
                                    context: context,
                                    message:
                                        'You are a member of this Organization',
                                  );
                                });
                              }
                            } else {
                              // join org and update data in firestore
                              // join org and update data in firestore
                              await orgProvider
                                  .addMemberToOrganization(
                                uid: uid,
                              )
                                  .whenComplete(() {
                                showSnackBar(
                                  context: context,
                                  message:
                                      'You are a member of this Organization',
                                );
                              });
                            }
                          },
                        ),
                if (orgProvider.organizationModel.organizationTerms.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // show terms and conditions dialog
                      MyDialogs.animatedTermsDialog(
                          context: context,
                          title: "Terms and Conditions",
                          content:
                              orgProvider.organizationModel.organizationTerms,
                          isMember: orgProvider.organizationModel.membersUIDs
                              .contains(uid),
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
                  ),
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
