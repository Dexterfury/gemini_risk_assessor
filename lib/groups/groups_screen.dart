import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase/analytics_helper.dart';
import 'package:gemini_risk_assessor/groups/group_details.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/search/group_search_stream.dart';
import 'package:gemini_risk_assessor/firebase/groups_stream.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/responsive_layout_helper.dart';
import 'package:gemini_risk_assessor/widgets/anonymouse_view.dart';
import 'package:gemini_risk_assessor/widgets/build_user_image.dart';
import 'package:gemini_risk_assessor/app_bars/my_app_bar.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  GroupModel? selectedGroup;

  void selectGroup(GroupModel group) {
    setState(() {
      selectedGroup = group;
    });
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logScreenView(
      screenName: 'Groups Screen',
      screenClass: 'GroupsScreen',
    );
    bool isAnonymous = context.read<AuthenticationProvider>().isUserAnonymous();
    return Consumer<GroupProvider>(builder: (context, groupProvider, child) {
      handleSearch(String query) {
        if (!isAnonymous) {
          groupProvider.setSearchQuery(query);
        }
      }

      return Scaffold(
        appBar: MyAppBar(
          title: '',
          onSearch: handleSearch,
          actions: [BuildUserImage()],
        ),
        body: isAnonymous
            ? const AnonymouseView(
                message: 'Please Sign In to view groups',
              )
            : ResponsiveLayoutHelper.responsiveBuilder(
                context: context,
                mobile: _buildMobileLayout(groupProvider, isAnonymous),
                tablet: _buildTabletLayout(groupProvider, isAnonymous),
                desktop: _buildDesktopLayout(groupProvider, isAnonymous),
              ),
      );
    });
  }

  Widget _buildMobileLayout(GroupProvider groupProvider, bool isAnonymous) {
    return groupProvider.searchQuery.isEmpty
        ? GroupsStream(onGroupTap: selectGroup)
        : GroupsSearchStream(onGroupTap: selectGroup);
  }

  Widget _buildTabletLayout(GroupProvider groupProvider, bool isAnonymous) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: groupProvider.searchQuery.isEmpty
              ? GroupsStream(onGroupTap: selectGroup)
              : GroupsSearchStream(onGroupTap: selectGroup),
        ),
        Expanded(
          flex: 3,
          child: selectedGroup != null
              ? GroupDetails(groupModel: selectedGroup!)
              : Center(
                  child: Text(
                    'Select a group to view details',
                    style: AppTheme.textStyle18w500,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(GroupProvider groupProvider, bool isAnonymous) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: groupProvider.searchQuery.isEmpty
              ? GroupsStream(onGroupTap: selectGroup)
              : GroupsSearchStream(onGroupTap: selectGroup),
        ),
        Expanded(
          flex: 2,
          child: selectedGroup != null
              ? GroupDetails(groupModel: selectedGroup!)
              : Center(
                  child: Text(
                    'Select a group to view details',
                    style: AppTheme.textStyle18w500,
                  ),
                ),
        ),
      ],
    );
  }
}
