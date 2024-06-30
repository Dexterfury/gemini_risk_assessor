import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/streams/tools_stream.dart';
import 'package:provider/provider.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().userModel!.uid;
    final toolProvider = context.read<ToolsProvider>();
    return SafeArea(
      child: ToolsStream(
        toolProvider: toolProvider,
        uid: uid,
      ),
    );
  }
}
