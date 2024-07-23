import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DiscussionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Widget> actions;

  const DiscussionAppBar({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: actions,
      flexibleSpace: imageUrl.isNotEmpty
          ? FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Usage example:
// DiscussionAppBar(
//   title: appBarTitle,
//   subtitle: appBarSubtitle,
//   imageUrl: appBarImage,
//   actions: [
//     Padding(
//       padding: const EdgeInsets.only(right: 8.0),
//       child: GeminiFloatingChatButton(
//         onPressed: () {},
//         size: ChatButtonSize.small,
//         iconColor: Colors.white,
//       ),
//     )
//   ],
// )
