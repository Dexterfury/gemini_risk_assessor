import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:provider/provider.dart';

class InfoDetailsCard extends StatefulWidget {
  const InfoDetailsCard({
    super.key,
    required this.myProfile,
    required this.userModel,
  });

  final bool myProfile;
  final UserModel userModel;

  @override
  State<InfoDetailsCard> createState() => _InfoDetailsCardState();
}

class _InfoDetailsCardState extends State<InfoDetailsCard> {
  File? _finalFileImage;

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

  Widget getEditWidget(
    String title,
    String content,
    String uid,
    String profileName,
    String aboutMe,
  ) {
    // check if user is admin
    if (widget.myProfile) {
      return GestureDetector(
        onTap: () {
          MyDialogs.showMyEditAnimatedDialog(
            context: context,
            title: title,
            content: content,
            hintText: content == Constants.changeName ? profileName : aboutMe,
            textAction: "Change",
            onActionTap: (value, updatedText) async {
              final authProvider = context.read<AuthProvider>();
              if (value) {
                if (content == Constants.changeName) {
                  final name = await authProvider.updateName(
                    isUser: true,
                    id: uid,
                    newName: updatedText,
                    oldName: profileName,
                  );
                  if (name == 'Invalid name.') return;
                  await authProvider.setName(name);
                } else {
                  final desc = await authProvider.updateDescription(
                    isUser: true,
                    id: uid,
                    newDesc: updatedText,
                    oldDesc: aboutMe,
                  );
                  if (desc == 'Invalid description.') return;
                  authProvider.setDescription(desc);
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
  }

  // set new image from file and update provider
  Future<void> setNewImageInProvider(String imageUrl) async {
    // set newimage in provider
    await context.read<AuthProvider>().setImageUrl(imageUrl);
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
    final uid = widget.userModel.uid;
    // get profile name
    final profileName = widget.userModel.name;
    // phone number
    final phoneNumber = widget.userModel.phone;
    // get profile image
    final profileImage = widget.userModel.imageUrl;

    // get about me
    final aboutMe = widget.userModel.aboutMe;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DisplayUserImage(
                  radius: 50,
                  isViewOnly: !widget.myProfile,
                  fileImage: _finalFileImage,
                  imageUrl: profileImage,
                  onPressed: () async {
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
                        isUser: true,
                        id: widget.userModel.uid,
                        reference:
                            '${Constants.userImages}/${widget.userModel.uid}.jpg',
                      );

                      // set newimage in provider
                      await setNewImageInProvider(imageUrl);

                      // pop loading dialog
                      popDialog();
                    }
                  },
                ),
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
                            uid,
                            profileName,
                            aboutMe,
                          ),
                        ],
                      ),
                      // display phone number
                      widget.myProfile
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
                const Text('About Me',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                getEditWidget(
                  'Change Status',
                  Constants.changeDescription,
                  uid,
                  profileName,
                  aboutMe,
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
