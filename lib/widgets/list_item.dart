import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemini_risk_assessor/models/assessment_model.dart';
import 'package:gemini_risk_assessor/utilities/my_image_cache_manager.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.data,
  });

  final AssessmentModel data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
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
      trailing: Icon(
        Platform.isIOS ? Icons.arrow_forward_ios : Icons.arrow_forward,
      ),
    );
    ;
  }
}
