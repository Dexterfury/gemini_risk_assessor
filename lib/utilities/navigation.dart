import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';

navigationController({
  required BuildContext context,
  required String route,
  String titleArg = '',
  String orgArg = '',
}) {
  switch (route) {
    case Constants.screensControllerRoute:
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
      break;
    case Constants.userInformationRoute:
      Navigator.pushNamed(
        context,
        route,
      );
      break;
    case Constants.logingRoute:
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
      break;
    case Constants.profileRoute:
      Navigator.pushNamed(
        context,
        route,
        arguments: titleArg,
      );
      break;
    default:
      Navigator.pushNamed(
        context,
        route,
        arguments: {
          Constants.title: titleArg,
          Constants.orgArg: orgArg,
        },
      );
      break;
  }
}
