import 'package:eyflutter_uikit/uikit/images/enums/image_argument_type.dart';
import 'package:eyflutter_uikit/uikit/images/enums/oss_type.dart';
import 'package:eyflutter_uikit/uikit/images/oss/oss_aliyun_config.dart';

/// oss图片参数配置
class OssImageConfig {
  factory OssImageConfig() => _getInstance();

  static OssImageConfig get instance => _getInstance();
  static OssImageConfig _instance;

  OssImageConfig._internal();

  static OssImageConfig _getInstance() {
    if (_instance == null) {
      _instance = new OssImageConfig._internal();
    }
    return _instance;
  }

  /// 获取图片链接
  /// [originalUrl] 原图地址
  /// [arguments] 图片参数，参考[OssImageArguments]
  /// [ossType] 参考规则类型
  String getCustomUrl(String originalUrl, StringBuffer arguments, {OssType ossType = OssType.aliYun}) {
    if (ossType == OssType.aliYun) {
      var aliYunConfig = OssAliYunConfig();
      return aliYunConfig.getUrl(originalUrl, arguments);
    }
    return originalUrl;
  }

  /// 获取图片链接
  /// [originalUrl] 原图地址
  /// [argumentType] 组件图片参数类型[ImageArgumentType.custom]除外
  /// [ossType] 参考规则类型
  /// [width] 展示图片宽度argumentType == ImageArgumentType.resizeW或
  /// argumentType == ImageArgumentType.corners时生效
  /// [height] 展示图片高度argumentType == ImageArgumentType.resizeH时生效
  /// [radius] 当argumentType == ImageArgumentType.circle时指内切圆半径;
  /// 当argumentType==ImageArgumentType.corners时指圆角半径
  String getImageUrl(String originalUrl, ImageArgumentType argumentType,
      {OssType ossType = OssType.aliYun, double width, double height, double radius}) {
    if (ossType == OssType.aliYun) {
      var aliYunConfig = OssAliYunConfig();
      if (argumentType == ImageArgumentType.exif) {
        return aliYunConfig.getExifUrl(originalUrl);
      } else if (argumentType == ImageArgumentType.resizeW) {
        return aliYunConfig.getUrlResizeW(originalUrl, width);
      } else if (argumentType == ImageArgumentType.resizeH) {
        return aliYunConfig.getUrlResizeH(originalUrl, height);
      } else if (argumentType == ImageArgumentType.circle) {
        return aliYunConfig.getUrlCircle(originalUrl, radius);
      } else if (argumentType == ImageArgumentType.corners) {
        return aliYunConfig.getUrlCorners(originalUrl, width, radius);
      }
    }
    return originalUrl;
  }
}
