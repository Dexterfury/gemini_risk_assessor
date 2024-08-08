import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/screens/profile_screen.dart';
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
    this.onLongPress,
    this.onChanged,
  });

  final UserModel userData;
  final bool isAdminView;
  final bool showCheckMark;
  final UserViewType viewType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final name = userData.uid == uid ? 'You' : userData.name;

    return ListTile(
      minLeadingWidth: 0.0,
      contentPadding: EdgeInsets.zero,
      leading: GestureDetector(
        onTap: uid == userData.uid
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      uid: userData.uid,
                    ),
                  ),
                );
              },
        child: DisplayUserImage(
          radius: 30,
          imageUrl: userData.imageUrl,
          isViewOnly: true,
          onPressed: () {},
          avatarPadding: 0.0,
        ),
      ),
      title: Text(name),
      subtitle: Text(
        userData.aboutMe,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: showCheckMark
          ? _buildCheckbox(context)
          : isAdminView
              ? const Icon(Icons.admin_panel_settings_rounded)
              : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, orgProvider, _) {
        bool isChecked = _getValue(orgProvider);
        return Checkbox(
          value: isChecked,
          onChanged: (value) {
            _handleCheckBox(context, userData, value, viewType);
            if (onChanged != null) {
              onChanged!();
            }
          },
        );
      },
    );
  }

  bool _getValue(GroupProvider orgProvider) {
    switch (viewType) {
      case UserViewType.admin:
        return orgProvider.groupAdminsList
            .any((admin) => admin.uid == userData.uid);
      case UserViewType.creator:
        return orgProvider.awaitApprovalsList.contains(userData.uid);
      case UserViewType.tempPlus:
        return orgProvider.awaitApprovalsList.contains(userData.uid) ||
            orgProvider.tempGroupMemberUIDs.contains(userData.uid);
      default:
        return orgProvider.groupMembersList
            .any((member) => member.uid == userData.uid);
    }
  }
}

void _handleCheckBox(
  BuildContext context,
  UserModel userData,
  bool? value,
  UserViewType viewType,
) {
  final orgProvider = context.read<GroupProvider>();
  switch (viewType) {
    case UserViewType.admin:
      break;
    case UserViewType.creator:
      if (value == true) {
        orgProvider.addToWaitingApproval(groupMember: userData);
      } else {
        orgProvider.removeWaitingApproval(groupMember: userData);
      }
      break;
    case UserViewType.tempPlus:
      if (value == true) {
        orgProvider.addMemberToTempGroup(memberUID: userData.uid);
      } else {
        orgProvider.removeMemberFromTempGroup(memberUID: userData.uid);
      }
      break;
    default:
      print('Unhandled UserViewType');
  }
}
