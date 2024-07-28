import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_details_screen.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_model.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:provider/provider.dart';

class NearMissItem extends StatelessWidget {
  const NearMissItem({
    super.key,
    required this.nearMiss,
  });
  final NearMissModel nearMiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: AppTheme.cardElevation,
      child: OpenContainer(
        closedBuilder: (context, action) {
          return ListTile(
            title: Text(nearMiss.description),
            subtitle: Text(nearMiss.dateTime),
            onTap: () async {
              await context
                  .read<NearMissProvider>()
                  .updateNearMiss(nearMiss)
                  .whenComplete(action);
            },
          );
        },
        openBuilder: (context, action) {
          return NearMissDetailsScreen(
            isViewOnly: true,
          );
        },
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        closedElevation: 0,
        openElevation: 4,
        closedColor: Theme.of(context).cardColor,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
