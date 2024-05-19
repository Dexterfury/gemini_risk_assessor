import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';
import 'package:gemini_risk_assessor/widgets/add_image.dart';
import 'package:provider/provider.dart';

class AssessmentImages extends StatelessWidget {
  const AssessmentImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, _) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AddImage(onTap: () async {
                    assessmentProvider.showBottomSheet(
                        context: context,
                        onError: (error) {
                          showSnackBar(
                            context: context,
                            message: error.toString(),
                          );
                        });
                  }),
                ),
                for (var image in assessmentProvider.imagesFileList!)
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
                              assessmentProvider.removeFile(image: image);
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
          ),
        );
      },
    );
  }
}
