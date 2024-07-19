import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/providers/organization_provider.dart';
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
    this.onChanged,
  });

  final UserModel userData;
  final bool isAdminView;
  final bool showCheckMark;
  final UserViewType viewType;
  final VoidCallback? onTap;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final name = uid == userData.uid ? 'You' : userData.name;
    bool value = getValue(context, viewType);

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
              value: value,
              onChanged: (value) {
                _handleCheckBox(
                  context,
                  userData,
                  value,
                  viewType,
                );
                if (onChanged != null) {
                  onChanged!();
                }
              },
            )
          : isAdminView
              ? const Icon(Icons.admin_panel_settings_rounded)
              : null,
      onTap: onTap,
    );
  }

  getValue(BuildContext context, UserViewType viewType) {
    final orgProvider = context.watch<OrganizationProvider>();
    switch (viewType) {
      case UserViewType.admin:
        return orgProvider.orgAdminsList.contains(userData);
      case UserViewType.creator:
        return orgProvider.awaitApprovalsList.contains(userData.uid);
      case UserViewType.tempPlus:
        return orgProvider.awaitApprovalsList.contains(userData.uid) ||
            orgProvider.tempOrgMemberUIDs.contains(userData.uid);
      default:
        return orgProvider.orgMembersList.contains(userData);
    }
  }
}

void _handleCheckBox(
  BuildContext context,
  UserModel userData,
  bool? value,
  UserViewType viewType,
) {
  final orgProvider = context.read<OrganizationProvider>();
  switch (viewType) {
    case UserViewType.admin:
      break;
    case UserViewType.creator:
      if (value == true) {
        orgProvider.addToWaitingApproval(groupMember: userData);
      } else {
        orgProvider.removeWaitingApproval(orgMember: userData);
      }
      break;
    case UserViewType.tempPlus:
      if (value == true) {
        orgProvider.addMemberToTempOrg(memberUID: userData.uid);
      } else {
        orgProvider.removeMemberFromTempOrg(memberUID: userData.uid);
      }
      break;
    default:
      log('Unhandled UserViewType');
  }
}
