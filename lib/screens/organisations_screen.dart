import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';

class OrganisationsGridScreen extends StatelessWidget {
  const OrganisationsGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Organisations',
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        actions: const DisplayUserImage(),
      ),
      body: const Center(
        child: Text('Organisations'),
      ),
    );
  }
}
