import 'dart:developer';
import 'dart:io';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/buttons_row.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/buttons/my_fab_button.dart';
import 'package:gemini_risk_assessor/groups/group_details_card.dart';
import 'package:gemini_risk_assessor/models/data_settings.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/members_card.dart';
import 'package:gemini_risk_assessor/groups/groups_settings.dart';
import 'package:gemini_risk_assessor/screens/people_screen.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
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
      bool allowCreate = groupProvider.groupModel.allowCreate;

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
                GroupDetailsCard(
                  imageUrl: groupProvider.groupModel.groupImage ?? '',
                  groupName: groupProvider.groupModel.name,
                  isAdmin: isAdmin,
                  onChangeImage: isAdmin
                      ? () async {
                          final file =
                              await ImagePickerHandler.showImagePickerDialog(
                                  context: context);
                          if (file != null) {
                            setState(() {
                              _finalFileImage = file;
                            });
                            showLoadingDialog(title: 'Saving,');

                            final imageUrl =
                                await FileUploadHandler.updateImage(
                              file: file,
                              isUser: false,
                              id: groupProvider.groupModel.groupID,
                              reference:
                                  '${Constants.groupImage}/${groupProvider.groupModel.groupID}.jpg',
                            );

                            await setNewImageInProvider(imageUrl);
                            popDialog();
                          }
                        }
                      : null,
                  onEditName: isAdmin
                      ? () {
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
                        }
                      : null,
                  onAddPeople: isAdmin
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PeopleScreen(
                                userViewType: UserViewType.tempPlus,
                              ),
                            ),
                          );
                        }
                      : null,
                  onViewTerms: groupProvider.groupModel.groupTerms.isNotEmpty
                      ? () {
                          MyDialogs.animatedTermsDialog(
                            context: context,
                            title: "Terms and Conditions",
                            content: groupProvider.groupModel.groupTerms,
                            isMember: groupProvider.groupModel.membersUIDs
                                .contains(uid),
                            onAccept: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _hasReadTerms = true;
                              });
                            },
                            onDecline: () {
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      : null,
                  showAcceptBtn: showAcceptBtn,
                  isLoading: groupProvider.isLoading,
                  acceptButton: _buildAcceptBtn(groupProvider, context, uid),
                ),
                Card(
                  color: Theme.of(context).cardColor,
                  elevation: AppTheme.cardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
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
        floatingActionButton: getCreateBtn(
          isAdmin,
          allowCreate,
          groupID,
        ),
      );
    });
  }

  Widget? getCreateBtn(
    bool isAdmin,
    bool allowCreate,
    String groupID,
  ) {
    if (isAdmin || allowCreate) {
      return MyFabButton(
        animationController: _animationController,
        animation: _animation,
        groupID: groupID,
      );
    } else {
      return null;
    }
  }

  buildExitCard(
    bool isAdmin,
    String uid,
    String groupID,
    GroupProvider groupProvider,
  ) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: AppTheme.cardElevation,
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

  buildName(
    bool isAdmin,
    GroupProvider groupProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            groupProvider.groupModel.name,
            style: AppTheme.textStyle18Bold,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
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
                    final authProvider = context.read<AuthenticationProvider>();
                    final name = await authProvider.updateName(
                      isUser: false,
                      id: groupProvider.groupModel.groupID,
                      newName: updatedText,
                      oldName: groupProvider.groupModel.name,
                    );
                    if (name == 'Invalid name.') return;
                    // set new name
                    await setNewNameInProvider(name);
                    Future.delayed(const Duration(milliseconds: 200))
                        .whenComplete(() {
                      showSnackBar(
                          context: context, message: 'Change successful');
                    });
                  }
                },
              );
            },
            child: Text(
              'Edit',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Column buildDescription(
    bool isAdmin,
    GroupProvider groupProvider,
  ) {
    final desc = groupProvider.groupModel.aboutGroup;

    // If not admin and description is empty, return an empty widget
    if (!isAdmin && desc.isEmpty) {
      return const Column(children: []);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAdmin && desc.isEmpty ? 'Add About Us' : 'About Us',
              style: AppTheme.textStyle18Bold,
            ),
            if (isAdmin)
              GestureDetector(
                onTap: () {
                  // edit group description
                  MyDialogs.showMyEditAnimatedDialog(
                    context: context,
                    title:
                        desc.isEmpty ? 'Add Description' : 'Edit Description',
                    maxLength: 500,
                    hintText: groupProvider.groupModel.aboutGroup,
                    textAction: desc.isEmpty ? "Add" : "Change",
                    onActionTap: (value, updatedText) async {
                      if (value) {
                        final authProvider =
                            context.read<AuthenticationProvider>();
                        final newDesc = await authProvider.updateDescription(
                          isUser: false,
                          id: groupProvider.groupModel.groupID,
                          newDesc: updatedText,
                          oldDesc: groupProvider.groupModel.aboutGroup,
                        );
                        if (newDesc == 'Invalid description.') return;
                        await setNewDescriptionInProvider(newDesc);
                        Future.delayed(const Duration(milliseconds: 200))
                            .whenComplete(() {
                          showSnackBar(
                            context: context,
                            message: desc.isEmpty
                                ? 'Description added'
                                : 'Description updated',
                          );
                        });
                      }
                    },
                  );
                },
                child: Text(
                  desc.isEmpty ? 'Add' : 'Edit',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        // divider
        const Divider(
          thickness: 1,
          color: Colors.black26,
        ),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 5),
          AnimatedReadMoreText(
            desc,
            maxLines: 3,
            textStyle: const TextStyle(fontSize: 16),
            buttonTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  buildImageAndTerms(
    bool isAdmin,
    BuildContext context,
    bool showAcceptBtn,
    GroupProvider groupProvider,
    String uid,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groupProvider.groupModel.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isAdmin)
              OpenContainer(
                closedBuilder: (context, action) {
                  return TextButton.icon(
                    icon: const Icon(Icons.person_add,
                        size: 18, color: Colors.white),
                    label: const Text('Add People',
                        style: TextStyle(color: Colors.white)),
                    onPressed: action,
                  );
                },
                openBuilder: (context, action) {
                  return const PeopleScreen(
                    userViewType: UserViewType.tempPlus,
                  );
                },
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 500),
                closedColor: Colors.transparent,
                closedElevation: 0,
                openElevation: 4,
              ),
            if (showAcceptBtn)
              groupProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : _buildAcceptBtn(groupProvider, context, uid),
            if (groupProvider.groupModel.groupTerms.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.description,
                    size: 18, color: Colors.white),
                label:
                    const Text('Terms', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  MyDialogs.animatedTermsDialog(
                    context: context,
                    title: "Terms and Conditions",
                    content: groupProvider.groupModel.groupTerms,
                    isMember:
                        groupProvider.groupModel.membersUIDs.contains(uid),
                    onAccept: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _hasReadTerms = true;
                      });
                    },
                    onDecline: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Card _buildAcceptBtn(
      GroupProvider groupProvider, BuildContext context, String uid) {
    return Card(
      color: Colors.orangeAccent,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () async {
            // accept invite
            // first check if admin set to read terms and conditions
            if (groupProvider.groupModel.requestToReadTerms) {
              if (!_hasReadTerms) {
                MyDialogs.animatedTermsDialog(
                    context: context,
                    title: "Terms and Conditions",
                    content: groupProvider.groupModel.groupTerms,
                    isMember:
                        groupProvider.groupModel.membersUIDs.contains(uid),
                    onAccept: () {
                      // Handle acceptance here
                      // join group and update data in firestore
                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {
                        _hasReadTerms = true;
                      });
                    },
                    onDecline: () {
                      // Handle decline here
                      Navigator.of(context).pop(); // Close the dialog
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
          child: FittedBox(
            child: Text(
              'Accept Invite',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
