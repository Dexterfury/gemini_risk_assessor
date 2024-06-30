import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/streams/organisations_stream.dart';
import 'package:gemini_risk_assessor/widgets/anonymouse_view.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';
import 'package:gemini_risk_assessor/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class OrganisationsScreen extends StatelessWidget {
  const OrganisationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = context.watch<AuthProvider>().isUserAnonymous();
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
            imageUrl: context.watch<AuthProvider>().userModel?.imageUrl ?? '',
            onPressed: () {},
          ),
        ),
        body:
            isAnonymous ? const AnonymouseView() : const OrganisationsStream());
  }
}
