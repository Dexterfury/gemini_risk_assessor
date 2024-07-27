import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/widgets/icon_container.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconContainerColor,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconContainerColor;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final containerColor = iconContainerColor ?? Theme.of(context).primaryColor;
    return ListTile(
      // added padding
      contentPadding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
      ),
      leading: IconContainer(
        icon: icon,
        color: containerColor,
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Icon(
        Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_forward_ios,
      ),
      onTap: onTap,
    );
  }
}
