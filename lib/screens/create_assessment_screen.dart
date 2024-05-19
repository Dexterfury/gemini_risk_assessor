import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/add_image.dart';
import 'package:gemini_risk_assessor/widgets/assessment_images.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:gemini_risk_assessor/widgets/ppe_gridview_widget.dart';
import 'package:image_picker/image_picker.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
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
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AddImage(onTap: () async {
              selectImages();
            }),
          ),
          for (var image in imagesFileList!)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.file(
                      File(image.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: GestureDetector(
                      onTap: () {
                        // remove image from list
                        imagesFileList!.removeWhere((file) => file == image);
                        setState(() {
                          // update maximum number of images
                          _maxImages = _maxImages + 1;
                          log('maxImages: $_maxImages');
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove_circle,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.all(
    //     8.0,
    //   ),
    //   child: SizedBox(
    //       height: 100,
    //       child: ListView.builder(
    //           scrollDirection: Axis.horizontal,
    //           itemCount: imagesFileList!.length,
    //           itemBuilder: (context, index) {
    //             final image = imagesFileList![index];
    //             return Padding(
    //               padding: const EdgeInsets.fromLTRB(
    //                 4.0,
    //                 8.0,
    //                 4.0,
    //                 0.0,
    //               ),
    //               child: ClipRRect(
    //                 borderRadius: BorderRadius.circular(15.0),
    //                 child: Image.file(
    //                   File(image.path),
    //                   height: 100,
    //                   width: 100,
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //             );
    //           })),
    // );
    // if (imagesFileList!.isNotEmpty) {
    //   return Padding(
    //     padding: const EdgeInsets.all(
    //       8.0,
    //     ),
    //     child: SizedBox(
    //         height: 100,
    //         child: ListView.builder(
    //             scrollDirection: Axis.horizontal,
    //             itemCount: imagesFileList!.length,
    //             itemBuilder: (context, index) {
    //               final image = imagesFileList![index];
    //               return Padding(
    //                 padding: const EdgeInsets.fromLTRB(
    //                   4.0,
    //                   8.0,
    //                   4.0,
    //                   0.0,
    //                 ),
    //                 child: ClipRRect(
    //                   borderRadius: BorderRadius.circular(15.0),
    //                   child: Image.file(
    //                     File(image.path),
    //                     height: 100,
    //                     width: 100,
    //                     fit: BoxFit.cover,
    //                   ),
    //                 ),
    //               );
    //             })),
    //   );
    // } else {
    //   return const Center(
    //       child: Text(
    //     "You have not \n \n picked images yet !",
    //     style: TextStyle(fontSize: 16),
    //     textAlign: TextAlign.center,
    //   ));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppBar(
        title: Constants.createAssessment,
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Add Project images'),
              AssessmentImages(),
              SizedBox(
                height: 20,
              ),
              PpeGridViewWidget(),
            ],
          ),
        ),
      )),
    );
  }
}
