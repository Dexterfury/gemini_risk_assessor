import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/groups/group_model.dart';
import 'package:gemini_risk_assessor/groups/group_provider.dart';
import 'package:gemini_risk_assessor/groups/group_details.dart';
import 'package:gemini_risk_assessor/themes/app_theme.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';
import 'package:provider/provider.dart';

class GroupGridItem extends StatelessWidget {
  const GroupGridItem({
    super.key,
    required this.groupModel,
  });

  final GroupModel groupModel;

  @override
  Widget build(BuildContext context) {
    String title = groupModel.name;
    String subtitle = groupModel.aboutGroup;
    String imageUrl = groupModel.groupImage!;
    ;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: AppTheme.cardElevation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxHeight * 0.8;
          final textHeight = constraints.maxHeight * 0.2;

          return OpenContainer(
            closedBuilder: (context, action) => InkWell(
              onTap: () async {
                context
                    .read<GroupProvider>()
                    .setGroupModel(groupModel: groupModel)
                    .whenComplete(() {
                  action();
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: constraints.maxWidth,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: MyImageCacheManager.showImage(
                        imageUrl: imageUrl,
                        isTool: false,
                      ),
                    ),
                  ),
                  SizedBox(height: textHeight * 0.1),
                  SizedBox(
                    height: textHeight * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        title,
                        style: AppTheme.textStyle16w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            openBuilder: (context, action) {
              return const GroupDetails();
            },
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration: const Duration(milliseconds: 500),
            closedElevation: 0,
            openElevation: 4,
            closedColor: Theme.of(context).cardColor,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            openShape: const RoundedRectangleBorder(),
          );
        },
      ),
    );
  }
}
