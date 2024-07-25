import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/dialogs/my_dialogs.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/models/user_model.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/user_widget.dart';
import 'package:provider/provider.dart';

class MembersCard extends StatelessWidget {
  const MembersCard({
    Key? key,
    required this.groupModel,
    required this.isAdmin,
  }) : super(key: key);

  final GroupModel groupModel;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: FutureBuilder<List<UserModel>>(
        future: context.read<GroupProvider>().getMembersDataFromFirestore(
              groupID: groupModel.groupID,
            ),
        builder: _buildMembersList,
      ),
    );
  }

  Widget _buildMembersList(
      BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      return const Center(child: Text('Something went wrong'));
    }

    final members = snapshot.data ?? [];
    if (members.isEmpty) {
      return const Center(child: Text('No members'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) =>
          _buildMemberTile(context, members[index]),
    );
  }

  Widget _buildMemberTile(BuildContext context, UserModel member) {
    final uid = context.read<AuthenticationProvider>().userModel?.uid;
    final isMemberAdmin = groupModel.adminsUIDs.contains(member.uid);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: UserWidget(
        userData: member,
        isAdminView: isMemberAdmin,
        showCheckMark: false,
        viewType: UserViewType.user,
        onLongPress:
            _getOnLongPressCallback(context, member, uid, isMemberAdmin),
      ),
    );
  }

  VoidCallback? _getOnLongPressCallback(
    BuildContext context,
    UserModel member,
    String? uid,
    bool isMemberAdmin,
  ) {
    if (!isAdmin || member.uid == uid) return null;

    return () {
      final addToAdmins = !isMemberAdmin;
      final title = addToAdmins ? 'Add as admin' : 'Remove from Admins';
      final content = addToAdmins
          ? 'Are you sure to add ${member.name} as an admin?'
          : 'Are you sure to remove ${member.name} from Admins?';

      _showAdminActionDialog(
        context,
        title,
        content,
        member,
        addToAdmins,
      );
    };
  }

  void _showAdminActionDialog(
    BuildContext context,
    String title,
    String content,
    UserModel member,
    bool addToAdmins,
  ) {
    MyDialogs.showMyAnimatedDialog(
      context: context,
      title: title,
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _handleAdminAction(
            context,
            member,
            addToAdmins,
          ),
          child: const Text('Yes'),
        ),
      ],
    );
  }

  void _handleAdminAction(
    BuildContext context,
    UserModel member,
    bool addToAdmins,
  ) {
    Navigator.pop(context);
    context
        .read<GroupProvider>()
        .handleMemberChanges(
          memberData: member,
          groupID: groupModel.groupID,
          isAdding: addToAdmins,
        )
        .whenComplete(() {
      showSnackBar(
        context: context,
        message: addToAdmins
            ? '${member.name} added as admin'
            : '${member.name} removed from Admins',
      );
    });
  }
}
