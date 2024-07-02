import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/streams/tools_stream.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:provider/provider.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({
    super.key,
    this.orgID = '',
  });

  final String orgID;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final toolProvider = context.read<ToolsProvider>();
    return Scaffold(
      appBar: orgID.isNotEmpty
          ? MyAppBar(
              leading: const BackButton(),
              title: '',
              onSearch: _handleSearch,
            )
          : null,
      body: SafeArea(
        child: ToolsStream(
          toolProvider: toolProvider,
          uid: uid,
          orgID: orgID,
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    print('Searching for "$query" in tab: ');
    // Implement your search logic here
  }
}
