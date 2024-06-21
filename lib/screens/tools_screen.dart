import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/widgets/grid_item.dart';
import 'package:provider/provider.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final toolProvider = context.watch<ToolsProvider>();
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: toolProvider.toolsList.isEmpty
          ? const Center(
              child: Text('You have not saved any tools'),
            )
          : GridView.builder(
              itemCount: toolProvider.toolsList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final tool = toolProvider.toolsList[index];
                return GridItem(tool: tool);
              }),
    ));
  }
}
