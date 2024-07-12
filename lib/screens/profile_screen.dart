import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/authentication/login_screen.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/help/help_screen.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/notifications_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/action_button.dart';
import 'package:gemini_risk_assessor/widgets/anonymouse_view.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _finalFileImage;

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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false;
    // get profile data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    final authProvider = context.watch<AuthProvider>();
    bool isAnonymous = authProvider.isUserAnonymous();
    bool isMyProfile = uid == authProvider.uid;
    return Scaffold(
      appBar: const MyAppBar(
        leading: BackButton(),
        title: 'Profile',
      ),
      body: StreamBuilder(
        stream: FirebaseMethods.userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel =
              UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildImageView(
                                context,
                                isMyProfile,
                                userModel,
                                isAnonymous,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildNameView(
                                      userModel,
                                      isMyProfile,
                                      context,
                                      uid,
                                      isAnonymous,
                                    ),
                                    // display phone number
                                    isMyProfile
                                        ? Text(userModel.phone,
                                            style: textStyle16w600)
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
                          _buildAboutMe(
                            isMyProfile,
                            context,
                            userModel,
                            uid,
                            isAnonymous,
                          ),
                          Text(
                            userModel.aboutMe,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  !isMyProfile
                      ? const SizedBox()
                      : Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Settings',
                                style: textStyle18w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              child: Column(
                                children: [
                                  SettingsListTile(
                                    title: 'Notifications',
                                    icon: Icons.notifications,
                                    iconContainerColor: Colors.red,
                                    onTap: () {
                                      // navigate to account settings
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  SettingsListTile(
                                    title: 'Help',
                                    icon: Icons.help,
                                    iconContainerColor: Colors.yellow,
                                    onTap: () {
                                      // navigate to help center
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const HelpScreen()));
                                    },
                                  ),
                                  SettingsListTile(
                                    title: 'About',
                                    icon: Icons.info,
                                    iconContainerColor: Colors.blue,
                                    onTap: () {
                                      // navigate to account settings
                                    },
                                  ),
                                  ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      // added padding for the list tile
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    leading: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          isDarkMode
                                              ? Icons.nightlight_round
                                              : Icons.wb_sunny_rounded,
                                          color: isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    title: const Text('Change theme'),
                                    trailing: Switch(
                                        value: isDarkMode,
                                        onChanged: (value) {
                                          // set the isDarkMode to the value
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              child: Column(
                                children: [
                                  SettingsListTile(
                                    title: isAnonymous
                                        ? 'Create Account'
                                        : 'Logout',
                                    icon: Icons.logout_outlined,
                                    iconContainerColor: Colors.red,
                                    onTap: () {
                                      if (isAnonymous) {
                                        navigationController(
                                          context: context,
                                          route: Constants.logingRoute,
                                        );
                                        return;
                                      }
                                      MyDialogs.showMyAnimatedDialog(
                                          context: context,
                                          title: 'Logout',
                                          content:
                                              'Are you sure you want to logout?',
                                          actions: [
                                            ActionButton(
                                              label: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            ActionButton(
                                              label: const Text(
                                                'Log Out',
                                              ),
                                              onPressed: () {
                                                // logout
                                                context
                                                    .read<AuthProvider>()
                                                    .signOut()
                                                    .whenComplete(() {
                                                  // remove all routes and navigateo to loging screen
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen(),
                                                    ),
                                                    (route) => false,
                                                  );
                                                });
                                              },
                                            ),
                                          ]);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Row _buildAboutMe(
    bool isMyProfile,
    BuildContext context,
    UserModel userModel,
    String uid,
    bool isAnonymous,
  ) {
    editButton() {
      if (isAnonymous) {
        return const SizedBox.shrink();
      }
      if (isMyProfile) {
        return GestureDetector(
          onTap: () {
            MyDialogs.showMyEditAnimatedDialog(
              context: context,
              title: Constants.aboutMe,
              content: Constants.aboutMe,
              hintText: userModel.aboutMe,
              textAction: "Change",
              onActionTap: (value, updatedText) async {
                final authProvider = context.read<AuthProvider>();
                if (value) {
                  await authProvider.updateDescription(
                    isUser: true,
                    id: uid,
                    newDesc: updatedText,
                    oldDesc: userModel.aboutMe,
                  );
                }
              },
            );
          },
          child: const Icon(Icons.edit_rounded),
        );
      }
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('About Me',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        editButton(),
      ],
    );
  }

  _buildNameView(UserModel userModel, bool isMyProfile, BuildContext context,
      String uid, bool isAnonymous) {
    editIcon() {
      if (isAnonymous) {
        return const SizedBox.shrink();
      }

      if (isMyProfile) {
        return GestureDetector(
          onTap: () {
            MyDialogs.showMyEditAnimatedDialog(
              context: context,
              title: Constants.changeName,
              content: Constants.changeName,
              hintText: userModel.name,
              textAction: "Change",
              onActionTap: (value, updatedText) async {
                final authProvider = context.read<AuthProvider>();
                if (value) {
                  await authProvider.updateName(
                    isUser: true,
                    id: uid,
                    newName: updatedText,
                    oldName: userModel.name,
                  );
                }
              },
            );
          },
          child: const Icon(Icons.edit_rounded),
        );
      }
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          userModel.name,
          style: textStyle18Bold,
        ),
        const SizedBox(
          width: 10,
        ),
        editIcon()
      ],
    );
  }

  DisplayUserImage _buildImageView(
    BuildContext context,
    bool isMyProfile,
    UserModel userModel,
    bool isAnonymous,
  ) {
    viewOnly() {
      if (isAnonymous) {
        return true;
      }
      if (isMyProfile) {
        return false;
      }
      return true;
    }

    return DisplayUserImage(
      radius: 50,
      isViewOnly: viewOnly(),
      fileImage: _finalFileImage,
      imageUrl: userModel.imageUrl,
      onPressed: () async {
        if (isAnonymous) {
          showSnackBar(
            context: context,
            message: 'Sign In to change image',
          );
          return;
        }
        final file = await ImagePickerHandler.showImagePickerDialog(
          context: context,
        );
        if (file != null) {
          setState(() {
            _finalFileImage = file;
          });
          // show loading dialog
          showLoadingDialog(
            title: 'Saving Image',
          );

          final imageUrl = await FileUploadHandler.updateImage(
            file: file,
            isUser: true,
            id: userModel.uid,
            reference: '${Constants.userImages}/${userModel.uid}.jpg',
          );

          // set newimage in provider
          await setNewImageInProvider(imageUrl);

          // pop loading dialog
          popDialog();
        }
      },
    );
  }
}
