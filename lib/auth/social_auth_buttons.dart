import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.onTap,
  });

  final Function(SignInType) onTap;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: SignInType.values.where((authType) {
          // Hide the Apple button on Android
          if (authType == SignInType.apple && Platform.isAndroid) {
            return false;
          }
          return true;
        }).map((authType) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicHeight(
              child: InkWell(
                onTap: () => onTap(authType),
                child: Card(
                  elevation: 2,
                  child: Container(
                    height: 80.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        getAuthIcon(authType),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
