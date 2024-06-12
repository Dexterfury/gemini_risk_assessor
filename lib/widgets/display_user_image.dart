import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/utilities/assets_manager.dart';
import 'package:provider/provider.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.blue,
        backgroundImage: getImageToShow(authProvider),
      ),
    );
  }

  getImageToShow(AuthProvider authProvider) {
    if (authProvider.isSignedIn) {
      return NetworkImage(authProvider.userModel!.imageUrl);
    } else {
      return AssetImage(AssetsManager.userIcon);
    }
  }
}
