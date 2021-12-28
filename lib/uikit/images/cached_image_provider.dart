import 'package:cached_network_image/cached_network_image.dart';
import 'package:eyflutter_core/kit/utils/string/crypto_extension.dart';
import 'package:eyflutter_uikit/uikit/images/image_cache_manager.dart';

class CachedImageProvider {
  CachedImageProvider._();

  static CachedNetworkImageProvider imageProvider({required String url}) {
    var cacheKey = url.generateMd5();
    return CachedNetworkImageProvider(
      url,
      cacheKey: cacheKey,
      cacheManager: ImageCacheManager.instance,
    );
  }
}
