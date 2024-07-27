import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/appBars/my_app_bar.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:provider/provider.dart';

class NearMissDetailsScreen extends StatelessWidget {
  const NearMissDetailsScreen({
    super.key,
    this.isViewOnly = false,
  });

  final bool isViewOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: BackButton(),
        title: 'Near Miss Details',
      ),
      body: Consumer<NearMissProvider>(
        builder: (context, nearMissProvider, child) {
          final nearMiss = nearMissProvider.nearMiss;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(FontAwesomeIcons.calendarDay),
                      Text(nearMiss!.nearMissDateTime)
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
