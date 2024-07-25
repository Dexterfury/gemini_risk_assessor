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
      leading: BackButton(
        color: Colors.white,
      ),
      flexibleSpace: Stack(
        children: [
          if (imageUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox(),
              ),
            ),
          // Add a semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
            ),
          ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white, // Ensure text is white for contrast
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70, // Slightly transparent white for subtitle
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
      backgroundColor: Colors.transparent, // Make AppBar transparent
      elevation: 0, // Remove elevation
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// class DiscussionAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String subtitle;
//   final String imageUrl;
//   final List<Widget> actions;

//   const DiscussionAppBar({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     required this.imageUrl,
//     required this.actions,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           Text(
//             subtitle,
//             style: Theme.of(context).textTheme.bodySmall,
//           ),
//         ],
//       ),
//       actions: actions,
//       flexibleSpace: imageUrl.isNotEmpty
//           ? FlexibleSpaceBar(
//               background: CachedNetworkImage(
//                 imageUrl: imageUrl,
//                 fit: BoxFit.cover,
//                 errorWidget: (context, url, error) => const SizedBox(),
//               ),
//             )
//           : null,
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

