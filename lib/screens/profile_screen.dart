import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/action_button.dart';
import 'package:gemini_risk_assessor/widgets/info_details_card.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/settings_list_tile.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false;
    // get profile data from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    final authProvider = context.watch<AuthProvider>();
    bool isMyProfile = uid == authProvider.uid;
    return Scaffold(
      appBar: MyAppBar(
          leading: const BackButton(),
          title: isMyProfile ? 'Account' : 'Organisation Details'),
      body: StreamBuilder(
        stream: context.read<AuthProvider>().userStream(userID: uid),
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
                  InfoDetailsCard(
                    userModel: userModel,
                  ),
                  const SizedBox(height: 10),
                  Column(
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
                              title: 'Account',
                              icon: Icons.person,
                              iconContainerColor: Colors.deepPurple,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),
                            SettingsListTile(
                              title: 'My Media',
                              icon: Icons.image,
                              iconContainerColor: Colors.green,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),
                            SettingsListTile(
                              title: 'Notifications',
                              icon: Icons.notifications,
                              iconContainerColor: Colors.red,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Column(
                          children: [
                            SettingsListTile(
                              title: 'Help',
                              icon: Icons.help,
                              iconContainerColor: Colors.yellow,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),
                            SettingsListTile(
                              title: 'Share',
                              icon: Icons.share,
                              iconContainerColor: Colors.blue,
                              onTap: () {
                                // navigate to account settings
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: ListTile(
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
                                color: isDarkMode ? Colors.black : Colors.white,
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
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Column(
                          children: [
                            SettingsListTile(
                              title: 'Logout',
                              icon: Icons.logout_outlined,
                              iconContainerColor: Colors.red,
                              onTap: () {
                                MyDialogs.showMyAnimatedDialog(
                                    context: context,
                                    title: 'Logout',
                                    content: 'Are you sure you want to logout?',
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
                                          'Sign Out',
                                        ),
                                        onPressed: () {
                                          // logout
                                        },
                                      ),
                                    ]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
