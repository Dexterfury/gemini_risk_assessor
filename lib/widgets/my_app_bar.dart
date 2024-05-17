import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[200],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            Platform.isAndroid ? CupertinoIcons.settings_solid : Icons.settings,
            color: Colors.grey[200],
          ),
          onPressed: () {
            // settings
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
