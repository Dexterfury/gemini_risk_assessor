import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';

class OrganisationsScreen extends StatelessWidget {
  const OrganisationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Organisations',
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        actions: DisplayUserImage(
          radius: 20,
          isViewOnly: true,
          onPressed: () {},
        ),
      ),
      body: const Center(
        child: Text('Organisations'),
      ),
    );
  }
}
