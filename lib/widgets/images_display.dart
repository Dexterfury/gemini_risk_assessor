import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/assessment_provider.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:gemini_risk_assessor/widgets/add_image.dart';
import '../providers/tool_provider.dart';

class ImagesDisplay extends StatelessWidget {
  const ImagesDisplay({
    super.key,
    this.isViewOnly = false,
    this.assessmentProvider,
    this.toolProvider,
    this.assessmentModel,
  });

  final bool isViewOnly;
  final AssessmentProvider? assessmentProvider;
  final ToolsProvider? toolProvider;
  final AssessmentModel? assessmentModel;

  @override
  Widget build(BuildContext context) {
    final provider = getProvider(assessmentProvider, toolProvider);
    return getImagesToShow(provider);
  }

  Container _assessmentViewImages() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var image in assessmentModel!.images)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: MyImageCacheManager.showImage(
                            imageUrl: image,
                            isTool: false,
                          ),
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  getImagesToShow(dynamic provider) {
    if (isViewOnly && provider != null && provider.imagesFileList!.isEmpty) {
      return const Text('No images added');
    } else if (isViewOnly && assessmentModel != null) {
      return _assessmentViewImages();
    } else {
      return ProviderViewImages(
        isViewOnly: isViewOnly,
        provider: provider,
      );
    }
  }

  getProvider(
    AssessmentProvider? assessmentProvider,
    ToolsProvider? toolProvider,
  ) {
    if (assessmentProvider != null) {
      return assessmentProvider;
    } else if (toolProvider != null) {
      return toolProvider;
    } else {
      return null;
    }
  }
}

class ProviderViewImages extends StatelessWidget {
  const ProviderViewImages({
    super.key,
    required this.isViewOnly,
    required this.provider,
  });

  final bool isViewOnly;
  final dynamic provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isViewOnly ? null : Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: isViewOnly
            ? null
            : Border.all(
                width: 1,
                color: Colors.grey,
              ),
      ),
      child: SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            isViewOnly
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AddImage(onTap: () async {
                      provider.showImagePickerDialog(
                        context: context,
                      );
                    }),
                  ),
            for (var image in provider.imagesFileList!)
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
                    isViewOnly
                        ? const SizedBox.shrink()
                        : Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: () {
                                // remove image from list
                                provider.removeFile(image: image);
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
  }
}
