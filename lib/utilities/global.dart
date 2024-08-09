import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/buttons/main_app_button.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../tools/tool_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String cleanJson(String maybeInvalidJson) {
  if (maybeInvalidJson.contains('```')) {
    final withoutLeading = maybeInvalidJson.split('```json').last;
    final withoutTrailing = withoutLeading.split('```').first;
    return withoutTrailing;
  }
  return maybeInvalidJson;
}

// picp image from gallery or camera
Future<File?> pickUserImage({
  required bool fromCamera,
  required Function(String) onFail,
}) async {
  File? fileImage;
  if (fromCamera) {
    // get picture from camera
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        onFail('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  } else {
    // get picture from gallery
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail('No image selected');
      } else {
        fileImage = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }
  }

  return fileImage;
}

getCollectionRef(GenerationType generationType) {
  if (generationType == GenerationType.tool) {
    return Constants.toolsCollection;
  } else {
    return Constants.assessmentCollection;
  }
}

Widget messageToShow({
  required MessageType type,
  required String message,
}) {
  switch (type) {
    case MessageType.text:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    case MessageType.image:
      return const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(width: 10),
          Text(
            'Image',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageType.video:
      return const Row(
        children: [
          Icon(Icons.video_library_outlined),
          SizedBox(width: 10),
          Text(
            'Video',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    case MessageType.audio:
      return const Row(
        children: [
          Icon(Icons.audiotrack_outlined),
          SizedBox(width: 10),
          Text(
            'Audio',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    default:
      return Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
  }
}

// validate email method
bool validateEmail(String email) {
  // Regular expression for email validation
  final RegExp emailRegex =
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  // Check if the email matches the regular expression
  return emailRegex.hasMatch(email);
}

// show snackbar
showSnackBar({
  required BuildContext context,
  required String message,
  Color backgroundColor = Colors.black,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// get label
getLabel(ListHeader label) {
  switch (label) {
    case ListHeader.equipments:
      return 'Equipments:';
    case ListHeader.hazards:
      return 'Hazards:';
    case ListHeader.risks:
      return 'Risks:';
    case ListHeader.control:
      return 'Control Measures:';
    case ListHeader.ppe:
      return 'Personal Project Equipment (PPE):';
    case ListHeader.signatures:
      return 'Signatures:';
    default:
      return 'Unknown';
  }
}

IconData getWeatherIcon(Weather weather) {
  return weather == Weather.sunny
      ? Icons.wb_sunny_outlined
      : weather == Weather.rain
          ? Icons.shower
          : weather == Weather.windy
              ? Icons.wind_power
              : Icons.snowing;
}

IconData getAuthIcon(SignInType signInType) {
  return signInType == SignInType.email
      ? FontAwesomeIcons.solidEnvelope
      : signInType == SignInType.google
          ? FontAwesomeIcons.google
          : signInType == SignInType.apple
              ? FontAwesomeIcons.apple
              : FontAwesomeIcons.solidCircleUser;
}

//  get count function
String getFormatedCount(
  int count,
) {
  if (count == 0) {
    return '';
  } else if (count == 1) {
    return '1';
  } else if (count < 100) {
    return count.toString();
  } else if (count < 1000) {
    return '$count+';
  } else if (count < 1000000) {
    return '${(count / 1000).floor()}k+';
  } else {
    return '${(count / 1000000).floor()}M+';
  }
}

// animated dialog

// general bacl icon
Widget backIcon(BuildContext context) {
  return IconButton(
    onPressed: () => Navigator.pop(context),
    icon: Icon(
      Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
    ),
  );
}

Widget previewImages({
  required BuildContext context,
  required List<dynamic> images,
  required PageController pageController,
  required bool isViewOnly,
}) {
  final toolsProvider = context.read<ToolsProvider>();

  if (images.isNotEmpty) {
    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: images.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final image = images[index];
            return GestureDetector(
              onTap: () {
                showMyImageViewer(
                  context,
                  images,
                  index,
                  isViewOnly,
                );
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.60,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: isViewOnly
                              ? Image.file(
                                  File(image),
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(image.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: GestureDetector(
                            onTap: () {
                              toolsProvider.removeFile(image: image);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // add images button
        Positioned(
          left: 20,
          bottom: 20,
          child: MainAppButton(
            icon: Icons.camera_alt_rounded,
            label: '+',
            onTap: () {
              toolsProvider.showImagePickerDialog(
                context: context,
              );
            },
          ),
        )
      ],
    );
  } else {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.60,
          width: MediaQuery.of(context).size.width,
          color: AppTheme.getDefaultImageTheme(context),
          child: Center(
            child: GestureDetector(
              onTap: () {
                toolsProvider.showImagePickerDialog(
                  context: context,
                );
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Click here to add images",
                    textAlign: TextAlign.center,
                    style: AppTheme.textStyle18w500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showMyImageViewer(
  BuildContext context,
  List<dynamic> images,
  int initialIndex,
  bool isViewOnly,
) {
  final List<ImageProvider> imageProviders = images
      .map((image) {
        if (image is XFile) {
          return FileImage(File(image.path));
        } else if (image is String && image.startsWith('http')) {
          return NetworkImage(image);
        } else {
          return AssetImage('assets/placeholder_image.png');
        }
      })
      .toList()
      .cast<ImageProvider>();

  MultiImageProvider multiImageProvider = MultiImageProvider(imageProviders);

  showImageViewerPager(
    context,
    multiImageProvider,
    onPageChanged: (page) {},
    onViewerDismissed: (page) {},
    swipeDismissible: true,
    doubleTapZoomable: true,
  );
}
