import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:eyflutter_core/kit/utils/string/path_extension.dart';
import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:eyflutter_uikit/uikit/images/beans/image_entry.dart';
import 'package:eyflutter_uikit/uikit/images/beans/image_response.dart';
import 'package:eyflutter_uikit/uikit/images/beans/native_image_entry.dart';

/// flutter: imageName:{packageName:path}
/// native: imageName:{android:name,ios:name}
class ImageListFactory {
  Map<String, ImageEntry> _flutterImageMap;
  Map<String, NativeImageEntry> _nativeImageMap;

  ImageListFactory() {
    _flutterImageMap = new HashMap<String, ImageEntry>();
    _nativeImageMap = new HashMap<String, NativeImageEntry>();
    flutterImageMap(_flutterImageMap);
    nativeImageMap(_nativeImageMap);
  }

  void flutterImageMap(Map<String, ImageEntry> imageMap) {}

  void nativeImageMap(Map<String, NativeImageEntry> imageMap) {}

  ImageEntry _getFlutterElementEntry(String imageName) {
    String realKey = _getRealKey(imageName);
    if (realKey.isEmptyString) {
      return null;
    }
    var imageEntry = _flutterImageMap[realKey];
    if (imageEntry.package.isEmptyString || imageEntry.path.isEmptyString) {
      return null;
    }
    return imageEntry;
  }

  int _getRatio() {
    double value = 1;
    double deviceRatio = window.devicePixelRatio;
    value = deviceRatio < 1 ? 1 : deviceRatio;
    value = deviceRatio > 3 ? 3 : deviceRatio;
    return value.toInt();
  }

  String _getRealKey(String imageName) {
    if (_flutterImageMap.containsKey(imageName)) {
      return imageName;
    }
    int ratio = _getRatio();
    if (_flutterImageMap.containsKey("${imageName}_${ratio}x")) {
      return "${imageName}_${ratio}x";
    }
    if (ratio == 2 && _flutterImageMap.containsKey("${imageName}_3x")) {
      return "${imageName}_3x";
    }
    if (ratio == 3 && _flutterImageMap.containsKey("${imageName}_2x")) {
      return "${imageName}_2x";
    }
    return "";
  }

  /// 根据图片名称或相对路径判断图片是否包含在flutter项目中
  /// [imageName] 图片名称
  bool hasFlutterImage(String imageName) {
    var realKey = _getRealKey(imageName);
    return realKey.isNotEmptyString;
  }

  /// 获取图片路径
  /// [imageName] 图片名
  ImageResponse getFlutterImageResponse(String imageName) {
    ImageEntry entry = _getFlutterElementEntry(imageName);
    if (entry == null) {
      return null;
    }
    return ImageResponse(
        result: "packages/${entry.package}/assets/${entry.path}",
        relative: "assets/${entry.path}",
        suffix: entry.suffix);
  }

  /// 根据图片名称检测native图片是否存在(该方式只做过滤不保证实际存在,实际图片通过[ImageWidget]加载时作判断.)
  /// [imageAlias] 图片别名
  bool hasNativeImage(String imageAlias) {
    return _nativeImageMap.containsKey(imageAlias);
  }

  /// 获取native图片名,通过[ImageWidget]方式加载,若返回null表示该图片不存在.
  /// [imageAlias] 图片别名
  ImageResponse getNativeImageResponse(String imageAlias) {
    var imageEntry = _nativeImageMap[imageAlias];
    if (imageEntry == null) {
      return null;
    }
    var image = '';
    var suffix = '';
    if (Platform.isIOS) {
      image = imageEntry.ios;
      suffix = image.suffixName;
    } else if (Platform.isAndroid) {
      image = imageEntry.android;
      suffix = image.suffixName;
    }
    if (image.isEmptyString) {
      return null;
    }
    return ImageResponse(result: image, suffix: suffix.isEmptyString ? "" : ".$suffix");
  }

  /// 根据图片名称或相对路径判断图片是否已存在
  /// [imageName] 图片名称或相对路径
  bool hasImage(String imageName) {
    if (hasFlutterImage(imageName)) {
      return true;
    }
    return hasNativeImage(imageName);
  }

  /// 获取图片路径或名称
  /// [nameOrAlias] 图片名称或别名
  String getImagePathOrName(String nameOrAlias) {
    var realKey = _getRealKey(nameOrAlias);
    if (realKey.isEmptyString) {
      NativeImageEntry entry = _nativeImageMap[nameOrAlias];
      if (entry == null) {
        return "";
      }
      if (Platform.isAndroid) {
        return entry.android;
      } else if (Platform.isIOS) {
        return entry.ios;
      }
      return "";
    }
    ImageEntry entry = _flutterImageMap[realKey];
    return "packages/${entry.package}/assets/${entry.path}";
  }
}
