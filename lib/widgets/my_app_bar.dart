import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.leading,
    this.userImage = const SizedBox(),
  });

  final String title;
  final Widget? leading;
  final Widget userImage;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      actions: [userImage],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
