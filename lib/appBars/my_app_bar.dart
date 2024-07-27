import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/search/animated_search_bar.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.bottom,
    this.onSearch,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final Function(String)? onSearch;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: onSearch != null
          ? AnimatedSearchBar(onSearch: onSearch!)
          : FittedBox(child: Text(title)),
      centerTitle: onSearch != null ? false : true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    if (bottom != null) {
      return Size.fromHeight(kToolbarHeight + bottom!.preferredSize.height);
    } else {
      return const Size.fromHeight(kToolbarHeight);
    }
  }
}
