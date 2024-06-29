import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:provider/provider.dart';

class InfoDetailsCard extends StatelessWidget {
  const InfoDetailsCard({
    super.key,
    this.isAdmin,
    this.userModel,
  });

  final bool? isAdmin;
  final UserModel? userModel;

  @override
  Widget build(BuildContext context) {
    // get current user
    final authProvider = context.watch<AuthProvider>();
    final uid = authProvider.userModel!.uid;
    final phoneNumber = authProvider.userModel!.phone;
    // get profile image
    final profileImage = userModel != null ? userModel!.imageUrl : '';
    // get profile name
    final profileName = userModel != null ? userModel!.name : '';

    // get group description
    final aboutMe = userModel != null ? userModel!.aboutMe : '';

    // get isOrganisation
    final isOrganisation = userModel != null ? false : true;

    Widget getEditWidget(
      String title,
      String content,
    ) {
      if (isOrganisation) {
        // check if user is admin
        if (isAdmin!) {
          return GestureDetector(
            onTap: () {
              showMyEditAnimatedDialog(
                context: context,
                title: title,
                content: content,
                hintText:
                    content == Constants.changeName ? profileName : aboutMe,
                textAction: "Change",
                onActionTap: (value, updatedText) async {
                  if (value) {
                    if (content == Constants.changeName) {
                      // final name = await authProvider.updateName(
                      //   isGroup: isGroup,
                      //   id: isGroup ? groupProvider!.groupModel.groupId : uid,
                      //   newName: updatedText,
                      //   oldName: profileName,
                      // );
                      // if (isGroup) {
                      //   if (name == 'Invalid name.') return;
                      //   groupProvider!.setGroupName(name);
                      // }
                    } else {
                      // final desc = await authProvider.updateStatus(
                      //   isGroup: isGroup,
                      //   id: isGroup ? groupProvider!.groupModel.groupId : uid,
                      //   newDesc: updatedText,
                      //   oldDesc: aboutMe,
                      // );
                      // if (isGroup) {
                      //   if (desc == 'Invalid description.') return;
                      //   groupProvider!.setGroupName(desc);
                      // }
                    }
                  }
                },
              );
            },
            child: const Icon(Icons.edit_rounded),
          );
        } else {
          return const SizedBox();
        }
      } else {
        if (userModel != null && userModel!.uid != uid) {
          return const SizedBox();
        }

        return GestureDetector(
          onTap: () {
            showMyEditAnimatedDialog(
              context: context,
              title: title,
              content: content,
              hintText: content == Constants.changeName ? profileName : aboutMe,
              textAction: "Change",
              onActionTap: (value, updatedText) {
                if (value) {
                  if (content == Constants.changeName) {
                    // authProvider.updateName(
                    //   isGroup: isGroup,
                    //   id: isGroup ? groupProvider!.groupModel.groupId : uid,
                    //   newName: updatedText,
                    //   oldName: profileName,
                    // );
                  } else {
                    // authProvider.updateStatus(
                    //   isGroup: isGroup,
                    //   id: isGroup ? groupProvider!.groupModel.groupId : uid,
                    //   newDesc: updatedText,
                    //   oldDesc: aboutMe,
                    // );
                  }
                }
              },
            );
          },
          child: const Icon(Icons.edit_rounded),
        );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // DisplayUserImage(
                //   radius: 50,
                //   isViewOnly: false,
                //   authProvider: authProvider,
                //   onPressed: () {
                //     authProvider.showImagePickerDialog(
                //       context: context,
                //     );
                //   },
                // ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            profileName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          getEditWidget(
                            'Change Name',
                            Constants.changeName,
                          ),
                        ],
                      ),
                      // display phone number
                      userModel != null && uid == userModel!.uid
                          ? Text(phoneNumber, style: textStyle16w600)
                          : const SizedBox.shrink(),

                      const SizedBox(height: 10),
                    ],
                  ),
                )
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    userModel != null ? 'About Me' : 'Organisation Description',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                getEditWidget(
                  'Change Status',
                  Constants.changeDescription,
                ),
              ],
            ),
            Text(
              aboutMe,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
