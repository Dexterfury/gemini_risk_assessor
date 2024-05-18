import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/widgets/display_user_image.dart';

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
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      actions: [
        GestureDetector(
            onTap: () {
              // navigate to profile page
            },
            child: const DisplayUserImage())
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
