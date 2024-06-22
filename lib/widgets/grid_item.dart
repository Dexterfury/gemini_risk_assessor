import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/screens/create_explainer_screen.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:provider/provider.dart';

class GridItem extends StatelessWidget {
  const GridItem({super.key, required this.tool});

  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxHeight * 0.8;
          final textHeight = constraints.maxHeight * 0.2;

          return OpenContainer(
            closedBuilder: (context, action) => InkWell(
              onTap: action,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: Image.file(
                        File(tool.images.first),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: textHeight * 0.1,
                  ), // Spacing between image and text
                  SizedBox(
                    height: textHeight * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        tool.name,
                        style: textStyle16w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            openBuilder: (context, action) => const CreateExplainerScreen(),
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 500),
            closedElevation: 0,
            openElevation: 4,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            openShape: const RoundedRectangleBorder(),
          );
        },
      ),
    );
  }
}
