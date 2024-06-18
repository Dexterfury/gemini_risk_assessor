import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/tools_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class CreateExplainerScreen extends StatefulWidget {
  const CreateExplainerScreen({super.key});

  @override
  State<CreateExplainerScreen> createState() => _CreateExplainerScreenState();
}

class _CreateExplainerScreenState extends State<CreateExplainerScreen> {
  Widget previewImages(ToolsProvider toolsProvider) {
    if (toolsProvider.imagesFileList!.isNotEmpty) {
      return ListView.builder(
          itemCount: toolsProvider.imagesFileList!.length,
          itemBuilder: (context, index) {
            return Image.file(File(toolsProvider.imagesFileList![index].path));
          });
    } else {
      return const Center(
          child: Text(
        "No image selected",
        textAlign: TextAlign.center,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tooProvider = context.watch<ToolsProvider>();
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: MyAppBar(
        leading: backIcon(context),
        title: 'Tool Explainer',
      ),
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.65,
            color: Colors.grey,
            child: previewImages(tooProvider),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Select Images'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Create Explainer'),
              )
            ],
          )
        ],
      ),
    );
  }
}
