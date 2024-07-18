import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/constants.dart';
import 'package:gemini_risk_assessor/enums/enums.dart';
import 'package:gemini_risk_assessor/providers/authentication_provider.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/utilities/global.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.authProvider,
  });

  final AuthenticationProvider authProvider;

  @override
  Widget build(BuildContext context) {
    handleClickedButton(SignInType authType) async {
      switch (authType) {
        case SignInType.email:
          // navigate to email sign in
          Navigator.pushNamed(
            context,
            Constants.emailSignInRoute,
          );
          break;
        case SignInType.google:
          await authProvider.socialLogin(
            context: context,
            signInType: SignInType.google,
          );
          break;
        case SignInType.apple:
          // handle apple sign in
          // handle anonymous
          await authProvider.socialLogin(
            context: context,
            signInType: SignInType.apple,
          );
          break;
        case SignInType.anonymous:
          // handle anonymous
          await authProvider.socialLogin(
            context: context,
            signInType: SignInType.anonymous,
          );
          break;
        default:
          log('Invalid sign in type');
      }
    }

    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final authType in SignInType.values)
            IntrinsicHeight(
              child: InkWell(
                onTap: () {
                  handleClickedButton(authType);
                },
                child: Card(
                  elevation: cardElevation,
                  child: Container(
                    height: 80.0,
                    width: 80.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
        ],
      ),
    );
  }
}
