import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GroupDetailsCard extends StatelessWidget {
  final String imageUrl;
  final String groupName;
  final bool isAdmin;
  final VoidCallback? onChangeImage;
  final VoidCallback? onEditName;
  final VoidCallback? onAddPeople;
  final VoidCallback? onViewTerms;
  final bool showAcceptBtn;
  final bool isLoading;
  final Widget? acceptButton;

  const GroupDetailsCard({
    Key? key,
    required this.imageUrl,
    required this.groupName,
    required this.isAdmin,
    this.onChangeImage,
    this.onEditName,
    this.onAddPeople,
    this.onViewTerms,
    this.showAcceptBtn = false,
    this.isLoading = false,
    this.acceptButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 1.0,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (imageUrl.isNotEmpty)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const SizedBox(),
                ),
              ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isAdmin && onEditName != null)
                          TextButton(
                            onPressed: onEditName,
                            child: Text(
                              'Edit Name',
                              style: TextStyle(color: Colors.blue[300]),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isAdmin && onChangeImage != null)
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                          onPressed: onChangeImage,
                        ),
                      Expanded(child: Container()), // Spacer
                      if (showAcceptBtn)
                        isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : acceptButton ?? Container(),
                      if (isAdmin && onAddPeople != null)
                        TextButton.icon(
                          icon: const Icon(Icons.person_add,
                              size: 18, color: Colors.white),
                          label: const Text('Add',
                              style: TextStyle(color: Colors.white)),
                          onPressed: onAddPeople,
                        ),
                      if (onViewTerms != null)
                        TextButton.icon(
                          icon: const Icon(Icons.description,
                              size: 18, color: Colors.white),
                          label: const Text('Terms',
                              style: TextStyle(color: Colors.white)),
                          onPressed: onViewTerms,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
