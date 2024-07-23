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
import 'package:gemini_risk_assessor/buttons/my_fab_button.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/members_card.dart';
import 'package:gemini_risk_assessor/groups/groups_settings.dart';
import 'package:gemini_risk_assessor/screens/people_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_group_image.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class GroupDetails extends StatefulWidget {
  const GroupDetails({
    super.key,
  });

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails>
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
    //setGroupModel();

    super.initState();
  }

  // void setGroupModel() async {
  //   // wait for widget  to be built before setting state
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context
  //         .read<GroupProvider>()
  //         .setGroupModel(groupModel: widget.groupModel);
  //   });
  // }

  // set new image from file and update provider
  Future<void> setNewImageInProvider(String imageUrl) async {
    // set newimage in provider
    await context.read<GroupProvider>().setImageUrl(imageUrl);
  }

  // set new name  in provider
  Future<void> setNewNameInProvider(String newName) async {
    // set new name in provider
    await context.read<GroupProvider>().setName(newName);
  }

  // set new description in provider
  Future<void> setNewDescriptionInProvider(String newDescription) async {
    // set new description in provider
    await context.read<GroupProvider>().setDescription(newDescription);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Consumer<GroupProvider>(builder: (context, groupProvider, child) {
      final groupModel = groupProvider.groupModel;
      bool isAdmin = groupModel.adminsUIDs.contains(uid);
      bool isMember = groupModel.membersUIDs.contains(uid);
      String groupID = groupModel.groupID;
      String groupTerms = groupModel.groupTerms;
      bool requestToReadTerms = groupProvider.groupModel.requestToReadTerms;
      bool allowSharing = groupProvider.groupModel.allowSharing;

      //String membersCount = getMembersCount(groupProvider.groupModel);
      bool showAcceptBtn =
          groupProvider.groupModel.awaitingApprovalUIDs.contains(uid);
      return Scaffold(
        appBar: MyAppBar(
          title: 'Group Details',
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
                        builder: (context) => GroupSettingsScreen(
                          isNew: false,
                          initialSettings: DataSettings(
                            requestToReadTerms: requestToReadTerms,
                            allowSharing: allowSharing,
                            groupTerms: groupTerms,
                          ),
                          onSave: (DataSettings settings) {
                            groupProvider.updateGroupSettings(settings);
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
                        //  group name and image
                        buildImageAndName(
                          isAdmin,
                          context,
                          showAcceptBtn,
                          groupProvider,
                          uid,
                        ),

                        const SizedBox(height: 10),

                        // divider
                        const Divider(
                          thickness: 1,
                          color: Colors.black26,
                        ),

                        //  group description
                        buildDescription(
                          isAdmin,
                          groupProvider,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                //  add members button if the user is an admin
                ButtonsRow(
                  groupID: groupID,
                  isAdmin: isAdmin,
                  isMember: isMember,
                ),

                const SizedBox(height: 10),

                // members list
                MembersCard(
                  groupModel: groupModel,
                  isAdmin: isAdmin,
                ),

                const SizedBox(height: 20),

                // members list if the user is an admin
                buildExitCard(
                  isAdmin,
                  uid,
                  groupID,
                  groupProvider,
                )
              ],
            ),
          ),
        ),
        floatingActionButton: MyFabButton(
          animationController: _animationController,
          animation: _animation,
          groupID: groupProvider.groupModel.groupID,
        ),
      );
    });
  }

  buildExitCard(
    bool isAdmin,
    String uid,
    String groupID,
    GroupProvider groupProvider,
  ) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: SettingsListTile(
        title: 'Exit Group',
        icon: FontAwesomeIcons.arrowRightFromBracket,
        iconContainerColor: Colors.red,
        onTap: () {
          // exit group
          MyDialogs.showMyAnimatedDialog(
            context: context,
            title: 'Exit Group',
            content: 'Are you sure you want to leave this Group?',
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

                  String result = await groupProvider.exitgroup(
                    isAdmin: isAdmin,
                    uid: uid,
                    groupID: groupID,
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
                        // pop the Group details Screen
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
    );
  }

  Column buildDescription(
    bool isAdmin,
    GroupProvider groupProvider,
  ) {
    final desc = groupProvider.groupModel.aboutGroup;
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
                        // edit group description
                        MyDialogs.showMyEditAnimatedDialog(
                          context: context,
                          title: 'Edit Description',
                          maxLength: 500,
                          hintText: groupProvider.groupModel.aboutGroup,
                          textAction: "Change",
                          onActionTap: (value, updatedText) async {
                            if (value) {
                              final authProvider =
                                  context.read<AuthenticationProvider>();
                              final desc = await authProvider.updateDescription(
                                isUser: false,
                                id: groupProvider.groupModel.groupID,
                                newDesc: updatedText,
                                oldDesc: groupProvider.groupModel.aboutGroup,
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
    GroupProvider groupProvider,
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
            child: DisplayGroupImage(
              isViewOnly: true,
              fileImage: _finalFileImage,
              imageUrl: groupProvider.groupModel.groupImage ?? '',
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
                          id: groupProvider.groupModel.groupID,
                          reference:
                              '${Constants.groupImage}/${groupProvider.groupModel.groupID}.jpg',
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
                        groupProvider.groupModel.name,
                        style: textStyle18Bold,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    if (isAdmin)
                      GestureDetector(
                        onTap: () {
                          // edit group name
                          MyDialogs.showMyEditAnimatedDialog(
                            context: context,
                            title: 'Edit Name',
                            hintText: groupProvider.groupModel.name,
                            textAction: "Change",
                            onActionTap: (value, updatedText) async {
                              if (value) {
                                final authProvider =
                                    context.read<AuthenticationProvider>();
                                final name = await authProvider.updateName(
                                  isUser: false,
                                  id: groupProvider.groupModel.groupID,
                                  newName: updatedText,
                                  oldName: groupProvider.groupModel.name,
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
                //                   .read<GroupProvider>()
                //                   .updateGroupDataInFireStore();

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
                //                   .read<GroupProvider>()
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
                  groupProvider.isLoading
                      ? const CircularProgressIndicator()
                      : MainAppButton(
                          icon: Icons.person_add,
                          label: 'Accept Invite',
                          contanerColor: Colors.orangeAccent,
                          onTap: () async {
                            // accept invite
                            // first check if admin set to read terms and conditions
                            if (groupProvider.groupModel.requestToReadTerms) {
                              if (!_hasReadTerms) {
                                MyDialogs.animatedTermsDialog(
                                    context: context,
                                    title: "Terms and Conditions",
                                    content:
                                        groupProvider.groupModel.groupTerms,
                                    isMember: groupProvider
                                        .groupModel.membersUIDs
                                        .contains(uid),
                                    onAccept: () {
                                      // Handle acceptance here
                                      // join group and update data in firestore
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
                                // join group and update data in firestore
                                await groupProvider
                                    .addMemberToGroup(
                                  uid: uid,
                                )
                                    .whenComplete(() {
                                  showSnackBar(
                                    context: context,
                                    message: 'You are a member of this Group',
                                  );
                                });
                              }
                            } else {
                              // join group and update data in firestore
                              await groupProvider
                                  .addMemberToGroup(
                                uid: uid,
                              )
                                  .whenComplete(() {
                                showSnackBar(
                                  context: context,
                                  message: 'You are a member of this Group',
                                );
                              });
                            }
                          },
                        ),
                if (groupProvider.groupModel.groupTerms.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // show terms and conditions dialog
                      MyDialogs.animatedTermsDialog(
                          context: context,
                          title: "Terms and Conditions",
                          content: groupProvider.groupModel.groupTerms,
                          isMember: groupProvider.groupModel.membersUIDs
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
  String getMembersCount(GroupModel groupModel) {
    int count = groupModel.membersUIDs.length;

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
