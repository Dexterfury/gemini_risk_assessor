import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/auth/authentication_provider.dart';
import 'package:gemini_risk_assessor/screens/profile_screen.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:provider/provider.dart';

class BuildUserImage extends StatelessWidget {
  const BuildUserImage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              uid: context.read<AuthenticationProvider>().userModel!.uid,
            ),
          ),
        );
      },
      child: DisplayUserImage(
        radius: 20,
        isViewOnly: true,
        imageUrl:
            context.watch<AuthenticationProvider>().userModel?.imageUrl ?? '',
        onPressed: () {},
      ),
    );
  }
}
