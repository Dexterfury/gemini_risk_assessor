import 'package:flutter/material.dart';
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
  });

  final UserModel userData;
  final bool isAdminView;
  final bool showCheckMark;
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final name = uid == userData.uid ? 'You' : userData.name;
    getValue() {
      return isAdminView
          ? context
              .watch<OrganisationProvider>()
              .orgAdminsList
              .contains(userData)
          : context
              .watch<OrganisationProvider>()
              .orgMembersList
              .contains(userData);
    }

    return ListTile(
      minLeadingWidth: 0.0,
      contentPadding: const EdgeInsets.only(left: -10),
      leading: DisplayUserImage(
        radius: 40,
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
              value: getValue(),
              onChanged: (value) {
                // check the check box
                if (isAdminView) {
                  if (value == true) {
                    context
                        .read<OrganisationProvider>()
                        .addMemberToAdmins(groupAdmin: userData);
                  } else {
                    context
                        .read<OrganisationProvider>()
                        .removeOrgAdmin(orgAdmin: userData);
                  }
                } else {
                  if (value == true) {
                    context
                        .read<OrganisationProvider>()
                        .addMemberToOrganisation(groupMember: userData);
                  } else {
                    context.read<OrganisationProvider>().removeOrgMember(
                          orgMember: userData,
                        );
                  }
                }
              },
            )
          : null,
    );
  }
}
