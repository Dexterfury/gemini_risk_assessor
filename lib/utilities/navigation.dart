import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';

navigationController({required BuildContext context, required String route}) {
  switch (route) {
    case Constants.homeRoute:
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
    default:
      Navigator.pushNamed(
        context,
        route,
      );
      break;
  }
}
