import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/organisation_provider.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:provider/provider.dart';

class UserWidget extends StatelessWidget {
  const UserWidget({
    super.key,
    required this.userData,
    this.isAdminView = false,
    required this.showCheckMark,
    required this.viewType,
    this.onTap,
  });

  final UserModel userData;
  final bool isAdminView;
  final bool showCheckMark;
  final UserViewType viewType;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final name = uid == userData.uid ? 'You' : userData.name;

    return ListTile(
      minLeadingWidth: 0.0,
      contentPadding: EdgeInsets.zero,
      leading: DisplayUserImage(
        radius: 30,
        imageUrl: userData.imageUrl,
        isViewOnly: true,
        onPressed: () {},
        avatarPadding: 0.0,
      ),
      title: Text(name),
      subtitle: Text(
        userData.aboutMe,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: showCheckMark
          ? Checkbox(
              value: getValue(
                context,
                viewType,
              ),
              onChanged: (value) {
                // check the check box
                if (value == true) {
                  context
                      .read<OrganisationProvider>()
                      .addToWaitingApproval(groupMember: userData);
                } else {
                  context
                      .read<OrganisationProvider>()
                      .removeWaitingApproval(orgMember: userData);
                }
              },
            )
          : isAdminView
              ? const Icon(Icons.admin_panel_settings_rounded)
              : null,
      onTap: onTap,
    );
  }

  getValue(
    BuildContext context,
    UserViewType viewType,
  ) {
    final orgProvider = context.watch<OrganisationProvider>();
    switch (viewType) {
      case UserViewType.admin:
        log('HERE 1');
        return orgProvider.orgAdminsList.contains(userData);
      case UserViewType.creator:
        log('HERE 2');
        return orgProvider.awaitApprovalsList.contains(
          userData,
        );
      case UserViewType.tempPlus:
        log('HERE 3');
        return orgProvider.awaitApprovalsList.contains(
              userData,
            ) ||
            orgProvider.orgMembersList.contains(
              userData,
            );
      default:
        log('HERE 4');
        return orgProvider.orgMembersList.contains(userData);
    }
  }
}
