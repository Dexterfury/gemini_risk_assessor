import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/models/tool_model.dart';
import 'package:gemini_risk_assessor/providers/tool_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
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

          return InkWell(
            onTap: () {
              // set the selected tool
              context.read<ToolProvider>().setTool(tool).whenComplete(() {
                Navigator.pushNamed(context, Constants.createToolRoute);
              });
            },
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
                    height: textHeight * 0.1), // Spacing between image and text
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
          );
        },
      ),
    );
  }
}
