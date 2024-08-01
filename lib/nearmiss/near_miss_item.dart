import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gemini_risk_assessor/authentication/authentication_provider.dart';
import 'package:gemini_risk_assessor/firebase_methods/firebase_methods.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_details_screen.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_model.dart';
import 'package:gemini_risk_assessor/nearmiss/near_miss_provider.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NearMissItem extends StatelessWidget {
  const NearMissItem({
    Key? key,
    required this.nearMiss,
  }) : super(key: key);

  final NearMissModel nearMiss;

  @override
  Widget build(BuildContext context) {
    final currentUserID = context.read<AuthenticationProvider>().userModel!.uid;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: OpenContainer(
        closedBuilder: (context, action) =>
            _buildClosedContainer(context, currentUserID, action),
        openBuilder: (context, action) =>
            NearMissDetailsScreen(isViewOnly: true),
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 500),
        closedElevation: 2,
        openElevation: 4,
        closedColor: Theme.of(context).cardColor,
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildClosedContainer(
      BuildContext context, String currentUserID, VoidCallback action) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          await context
              .read<NearMissProvider>()
              .updateNearMiss(nearMiss)
              .whenComplete(action);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  // Row(
                  //   children: [
                  //     Icon(Icons.warning_amber_rounded,
                  //         color: theme.colorScheme.error),
                  //     const SizedBox(width: 8),
                  //     Text(
                  //       'Near Miss Report',
                  //       style: textTheme.titleMedium
                  //           ?.copyWith(fontWeight: FontWeight.bold),
                  //     ),
                  //     const Spacer(),
                  //     _buildDateChip(context),
                  //   ],
                  // ),
                  //const SizedBox(height: 8),
                  Text(
                    nearMiss.description,
                    style: textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildFooter(
                context,
                currentUserID,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateChip(BuildContext context) {
    // Define the format of the incoming date string
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final date = dateFormat.parse(nearMiss.dateTime);

    // Format the parsed date to your desired output format
    final formattedDate = DateFormat('MMM d, y').format(date);
    return Chip(
      label: Text(
        formattedDate,
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildFooter(
    BuildContext context,
    String currentUserID,
  ) {
    // Define the format of the incoming date string
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final date = dateFormat.parse(nearMiss.dateTime);

    // Format the parsed date to your desired output format
    final formattedDate = DateFormat('MMM d, y').format(date);
    final theme = Theme.of(context);
    final captionColor = AppTheme.getCaptionColor(context);
    return Row(
      children: [
        Icon(FontAwesomeIcons.solidUser,
            size: 16, color: theme.colorScheme.secondary),
        const SizedBox(width: 4),
        Expanded(
          child: currentUserID == nearMiss.createdBy
              ? Text(
                  'You',
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: captionColor),
                )
              : getCreatorName(
                  context,
                  nearMiss.createdBy,
                ),
        ),
        Text(
          formattedDate,
          style: theme.textTheme.bodySmall?.copyWith(color: captionColor),
        )
      ],
    );
  }
}

Widget getCreatorName(BuildContext context, String createdBy) {
  final theme = Theme.of(context);
  final captionColor = AppTheme.getCaptionColor(context);
  return FutureBuilder<String>(
    future: FirebaseMethods.getCreatorName(createdBy),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          width: 100,
          child: LinearProgressIndicator(),
        );
      } else {
        String creatorName = snapshot.data ?? '';
        return Text(
          creatorName,
          style: theme.textTheme.bodySmall?.copyWith(color: captionColor),
        );
      }
    },
  );
}
// class NearMissItem extends StatelessWidget {
//   const NearMissItem({
//     super.key,
//     required this.nearMiss,
//   });
//   final NearMissModel nearMiss;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Theme.of(context).cardColor,
//       elevation: AppTheme.cardElevation,
//       child: OpenContainer(
//         closedBuilder: (context, action) {
//           return ListTile(
//             title: Text(nearMiss.description),
//             subtitle: Text(nearMiss.dateTime),
//             onTap: () async {
//               await context
//                   .read<NearMissProvider>()
//                   .updateNearMiss(nearMiss)
//                   .whenComplete(action);
//             },
//           );
//         },
//         openBuilder: (context, action) {
//           return NearMissDetailsScreen(
//             isViewOnly: true,
//           );
//         },
//         transitionType: ContainerTransitionType.fadeThrough,
//         transitionDuration: const Duration(milliseconds: 500),
//         closedElevation: 0,
//         openElevation: 4,
//         closedColor: Theme.of(context).cardColor,
//         closedShape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// }
