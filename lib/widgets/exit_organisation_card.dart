import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/themes/my_themes.dart';
import 'package:gemini_risk_assessor/widgets/settings_list_tile.dart';

class ExitCard extends StatelessWidget {
  const ExitCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: cardElevation,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SettingsListTile(
            title: 'Exit Organization',
            icon: Icons.exit_to_app,
            iconContainerColor: Colors.red,
            onTap: onTap),
      ),
    );
  }
}
