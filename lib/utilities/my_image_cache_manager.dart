import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gemini_risk_assessor/constants.dart';

class MyImageCacheManager {
  static CacheManager profileCacheManager = CacheManager(
    Config(Constants.userImageKey,
        maxNrOfCacheObjects: 20, stalePeriod: const Duration(days: 5)),
  );

  static CacheManager itemsCacheManager = CacheManager(
    Config(Constants.generatedImagesKey,
        maxNrOfCacheObjects: 100, stalePeriod: const Duration(days: 5)),
  );
}
