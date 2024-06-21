import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required PageController pageController,
    required this.images,
  }) : _pageController = pageController;

  final PageController _pageController;
  final List<dynamic> images;

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: images.length,
              effect: const WormEffect(
                dotHeight: 16,
                dotWidth: 16,
                type: WormType.normal,
              ),
            ),
          );
  }
}
