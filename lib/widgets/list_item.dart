import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/providers/auth_provider.dart';
import 'package:gemini_risk_assessor/screens/assessment_details_screen.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.docTitle,
    required this.data,
  });

  final String docTitle;
  final AssessmentModel data;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedBuilder: (context, action) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(
            height: 60,
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: data.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(
                    child: Icon(
                  Icons.error,
                  color: Colors.red,
                )),
                cacheManager: MyImageCacheManager.itemsCacheManager,
              ),
            ),
          ),
          title: Text(data.title),
          subtitle: Text(
            data.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: action,
        );
      },
      openBuilder: (context, action) {
        return AssessmentDetailsScreen(
          appBarTitle: docTitle,
          currentModel: data,
        );
      },
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 500),
      closedElevation: 0,
      openElevation: 4,
    );
  }
}
