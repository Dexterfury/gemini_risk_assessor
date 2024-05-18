import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:image_picker/image_picker.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  List<XFile>? imagesFileList = [];
  bool _fromCamera = false;
  int _maxImages = 10;

  void selectImages() async {
    final returnedFiles = await pickImages(
      fromCamera: _fromCamera,
      maxImages: _maxImages,
      onError: (error) {
        // show snackbar with error message
        showSnackBar(
          context: context,
          message: error.toString(),
        );
      },
    );
    if (returnedFiles != null) {
      // add each image into imagesFileList
      for (var file in returnedFiles) {
        imagesFileList!.add(file);
      }
      setState(() {
        // update maximum number of images
        _maxImages = _maxImages - returnedFiles.length;
        log('maxImages: $_maxImages');
      });
    }
  }

  Widget previewImages() {
    if (imagesFileList!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(
          8.0,
        ),
        child: SizedBox(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imagesFileList!.length,
                itemBuilder: (context, index) {
                  final image = imagesFileList![index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      4.0,
                      8.0,
                      4.0,
                      0.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.file(
                        File(image.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                })),
      );
    } else {
      return const Center(
          child: Text(
        "You have not \n \n picked images yet !",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: Constants.createAssessment,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Add Project images'),
            GestureDetector(
              onTap: () {
                selectImages();
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
                child: previewImages(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
              ),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: ppeIcons.length,
                  itemBuilder: (context, index) {
                    // get the first word of the game time
                    final ppeItem = ppeIcons[index];

                    return Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ppeItem.icon,
                          Text(
                            ppeItem.label,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      )),
    );
  }
}
