import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:eyflutter_uikit/uikit/images/enums/image_format.dart';
import 'package:eyflutter_uikit/uikit/images/oss/oss_image_arguments.dart';

class OssAliYunConfig {
  /// 取图片信息url
  /// [originalUrl] 原图地址
  String getExifUrl(String originalUrl) {
    if (originalUrl.isEmptyString) {
      return "";
    }
    if (originalUrl.indexOf("?") > 0) {
      return originalUrl;
    }
    return "$originalUrl?x-oss-process=image/info";
  }

  /// 图片拼接参数
  /// [originalUrl] 图片地址
  /// [arguments] oss图片参数
  String getUrl(String originalUrl, StringBuffer arguments) {
    if (originalUrl.isEmptyString) {
      return "";
    }
    if (originalUrl.indexOf("?") > 0) {
      return originalUrl;
    }
    return "$originalUrl?${arguments.toString()}";
  }

  /// 按宽度进行等比缩放
  /// [originalUrl] 图片地址
  /// [width] 缩放后图片宽度
  String getUrlResizeW(String originalUrl, double width) {
    var arguments = OssImageArguments().builder();
    arguments.resizeW(width);
    arguments.format(ImageFormat.webp);
    return getUrl(originalUrl, arguments.toBuffer());
  }

  /// 按高度进行等比缩放
  /// [originalUrl] 图片地址
  /// [width] 缩放后图片高度
  String getUrlResizeH(String originalUrl, double height) {
    var arguments = OssImageArguments().builder();
    arguments.resizeH(height);
    arguments.format(ImageFormat.webp);
    return getUrl(originalUrl, arguments.toBuffer());
  }

  /// 图片内切圆
  /// [originalUrl] 图片地址
  /// [radius] 圆半径
  String getUrlCircle(String originalUrl, double radius) {
    var arguments = OssImageArguments().builder();
    arguments.resizeW(radius * 2);
    arguments.circle(radius);
    arguments.format(ImageFormat.webp);
    return getUrl(originalUrl, arguments.toBuffer());
  }

  /// 圆角图片
  /// [originalUrl] 图片地址
  /// [width] 图片宽度
  /// [radius] 圆角半径
  String getUrlCorners(String originalUrl, double width, double radius) {
    var arguments = OssImageArguments().builder();
    arguments.resizeW(width);
    arguments.corners(radius);
    arguments.format(ImageFormat.webp);
    return getUrl(originalUrl, arguments.toBuffer());
  }
}
