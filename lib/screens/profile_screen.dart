import 'dart:io';
import 'package:animated_read_more_text/animated_read_more_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/auth/change_password.dart';
import 'package:gemini_risk_assessor/auth/login_screen.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/firebase/firebase_methods.dart';
import 'package:gemini_risk_assessor/help/help_screen.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/theme_provider.dart';
import 'package:gemini_risk_assessor/screens/about_screen.dart';
import 'package:gemini_risk_assessor/screens/notifications_screen.dart';
import 'package:gemini_risk_assessor/screens/safety_file_upload_widget.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:gemini_risk_assessor/utilities/file_upload_handler.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/utilities/image_picker_handler.dart';
import 'package:gemini_risk_assessor/utilities/navigation.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/icon_container.dart';
import 'package:gemini_risk_assessor/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _finalFileImage;
  late Future<UserModel> _userFuture;
  UserModel? _currentUserModel;

  // set new image from file and update provider
  Future<void> setNewImageInProvider(String imageUrl) async {
    // set newimage in provider
    await context.read<AuthenticationProvider>().setImageUrl(imageUrl);
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
  void initState() {
    AnalyticsHelper.logScreenView(
      screenName: 'Profile Screen',
      screenClass: 'ProfileScreen',
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userFuture = _loadUserData();
  }

  Future<UserModel> _loadUserData() async {
    final doc = await FirebaseMethods.usersCollection.doc(widget.uid).get();
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  void _updateUserModel(UserModel updatedModel) {
    setState(() {
      _currentUserModel = updatedModel;
    });
  }

  void _handleNameEdit(UserModel userModel) {
    MyDialogs.showMyEditAnimatedDialog(
      context: context,
      title: Constants.changeName,
      hintText: userModel.name,
      textAction: "Change",
      onActionTap: (value, updatedText) async {
        if (value) {
          final authProvider = context.read<AuthenticationProvider>();
          await authProvider.updateName(
            isUser: true,
            id: widget.uid,
            newName: updatedText,
            oldName: userModel.name,
          );
          _updateUserModel(userModel.copyWith(name: updatedText));
        }
      },
    );
  }

  void _handleAboutMeEdit(
    UserModel userModel,
  ) {
    MyDialogs.showMyEditAnimatedDialog(
      context: context,
      title: 'About Me',
      maxLength: 500,
      hintText: userModel.aboutMe,
      textAction: "Change",
      onActionTap: (value, updatedText) async {
        if (value) {
          final authProvider = context.read<AuthenticationProvider>();
          await authProvider.updateDescription(
            isUser: true,
            id: widget.uid,
            newDesc: updatedText,
            oldDesc: userModel.aboutMe,
          );
          _updateUserModel(userModel.copyWith(aboutMe: updatedText));
        }
      },
    );
  }

  Future<void> _handleImageChange(UserModel userModel) async {
    final file =
        await ImagePickerHandler.showImagePickerDialog(context: context);
    if (file != null) {
      setState(() {
        _finalFileImage = file;
      });
      showLoadingDialog(title: 'Saving Image');

      final imageUrl = await FileUploadHandler.updateImage(
        file: file,
        isUser: true,
        id: userModel.uid,
        reference: '${Constants.userImages}/${userModel.uid}.jpg',
      );

      await setNewImageInProvider(imageUrl);
      _updateUserModel(userModel.copyWith(imageUrl: imageUrl));

      popDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    bool canChangePassword = user != null &&
        user.providerData
            .any((userInfo) => userInfo.providerId == Constants.password);

    final authProvider = context.read<AuthenticationProvider>();
    bool isAnonymous = authProvider.isUserAnonymous();
    bool isMyProfile = widget.uid == authProvider.userModel?.uid;
    return Scaffold(
      appBar: MyAppBar(
        leading: BackButton(),
        title: 'Profile',
      ),
      body: FutureBuilder<UserModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userModel = _currentUserModel ?? snapshot.data!;

          return _buildProfileContent(
            isMyProfile,
            userModel,
            isAnonymous,
            widget.uid,
            canChangePassword,
          );
        },
      ),
    );
  }

  _buildProfileContent(
    bool isMyProfile,
    UserModel userModel,
    bool isAnonymous,
    String uid,
    bool canChangePassword,
  ) {
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
              color: Theme.of(context).cardColor,
              elevation: AppTheme.cardElevation,
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
                              if (isMyProfile && !isAnonymous)
                                Text(
                                    userModel.phone.isNotEmpty
                                        ? userModel.phone
                                        : userModel.email,
                                    style: AppTheme.textStyle16w600),

                              const SizedBox(height: 10),

                              // show safety points here
                              _buildSafetyPoints(userModel),
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
                    AnimatedReadMoreText(
                      userModel.aboutMe,
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
                          style: AppTheme.textStyle18w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: AppTheme.cardElevation,
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
                              onTap: () async {
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
                                // navigate to about screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutScreen(),
                                  ),
                                );
                              },
                            ),
                            if (canChangePassword)
                              SettingsListTile(
                                title: 'Change Password',
                                icon: Icons.lock,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePassword(),
                                    ),
                                  );
                                },
                              ),
                            SettingsListTile(
                              title: 'Safety File',
                              icon: Icons.health_and_safety_outlined,
                              iconContainerColor: Colors.green.shade700,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SafetyFileUploadWidget(
                                      userID: uid,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                              return ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  leading: IconContainer(
                                    icon: themeProvider.isDarkMode
                                        ? Icons.wb_sunny
                                        : Icons.nightlight_round,
                                  ),
                                  title: const Text('Change theme'),
                                  trailing: Switch(
                                    value: themeProvider.isDarkMode,
                                    onChanged: (value) {
                                      themeProvider.toggleTheme();
                                    },
                                  ));
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: AppTheme.cardElevation,
                        child: Column(
                          children: [
                            SettingsListTile(
                              title: isAnonymous ? 'Sign In' : 'Log Out',
                              icon: Icons.logout_outlined,
                              iconContainerColor: Colors.red,
                              onTap: () async {
                                if (isAnonymous) {
                                  navigationController(
                                    context: context,
                                    route: Constants.logingRoute,
                                  );
                                  return;
                                }
                                MyDialogs.showMyAnimatedDialog(
                                    context: context,
                                    title: 'Log Out',
                                    content: 'Are you sure you want to logout?',
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // logout
                                          context
                                              .read<AuthenticationProvider>()
                                              .signOut(context: context)
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
                                        child: const Text(
                                          'Yes',
                                        ),
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
  }

  _buildSafetyPoints(UserModel userModel) {
    if (userModel.safetyPoints == 0) {
      return const SizedBox();
    }
    int points = int.parse(userModel.safetyPoints.toStringAsFixed(0));
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
            height: 18,
            width: 18,
            child: Image.asset(
              AssetsManager.appLogo,
            )),
        const SizedBox(width: 5),
        Text(getFormatedCount(points),
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Row _buildAboutMe(
    bool isMyProfile,
    BuildContext context,
    UserModel userModel,
    String uid,
    bool isAnonymous,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('About Me',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        if (isMyProfile && !isAnonymous)
          GestureDetector(
            onTap: () {
              _handleAboutMeEdit(userModel);
            },
            child: Text(
              'Edit',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
      ],
    );
  }

  _buildNameView(
    UserModel userModel,
    bool isMyProfile,
    BuildContext context,
    String uid,
    bool isAnonymous,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          userModel.name,
          style: AppTheme.textStyle18Bold,
        ),
        const SizedBox(
          width: 10,
        ),
        if (isMyProfile && !isAnonymous)
          GestureDetector(
            onTap: () {
              _handleNameEdit(userModel);
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
        _handleImageChange(userModel);
      },
    );
  }
}
