import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eyflutter_core/kit/parts/config_manager.dart';
import 'package:eyflutter_core/kit/utils/string/crypto_extension.dart';
import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:eyflutter_uikit/constants/image_key.dart';
import 'package:eyflutter_uikit/uikit/images/asset_image_provider.dart';
import 'package:eyflutter_uikit/uikit/images/beans/image_response.dart';
import 'package:eyflutter_uikit/uikit/images/cached_image_provider.dart';
import 'package:eyflutter_uikit/uikit/images/image_cache_manager.dart';
import 'package:eyflutter_uikit/uikit/images/image_list_factory.dart';
import 'package:eyflutter_uikit/uikit/images/mp4_image_provider.dart';
import 'package:eyflutter_uikit/uikit/images/native_image_provider.dart';
import 'package:flutter/material.dart';

/// 构建图片url
/// [extensionData] 组件传入的扩展数据
typedef OnBuildImageUrlCall = String Function(ImageExtensionData extensionData);

/// 图片控件构建结束回调
typedef OnBuildFinishedCall = void Function(ImageController controller);

/// 扩展数据
class ImageExtensionData {
  final dynamic data;

  ImageExtensionData({this.data});
}

/// 图片控制器
mixin ImageController {
  void notifyUpdate(String urlOrAlias);
}

/// 图片组件配置
mixin OnImageWidgetConfig {
  /// 失败图片
  String onFailureImage();

  /// 默认图片
  String onDefaultImage();
}

/// 图片加载器
/// 1.通过chflutter -ipg -img-path-gen命令生成所有插件包包含的图片路径去重后生成FlutterImageLists;
/// 2.先从flutter项目查找并加载图片若没有再从native加载;
class ImageWidget extends StatefulWidget {
  /// 图片网络地址或别名[ImageNamesAlias],与buildUrlCall互斥
  /// eg. urlOrName: "share_logo_qq.png->shareLogoQq"
  final String urlOrAlias;

  /// 图片宽
  final double? width;

  /// 图片高
  final double? height;

  ///图片填充类型
  final BoxFit? fit;

  /// 圆角大小
  final BorderRadius? borderRadius;

  /// 背影颜色
  final Color? backgroundColor;

  /// 占位图(flutter assets图片)
  final String? placeholder;

  /// 占位图图片别名
  /// flutter项目图片：图片名称(xxx.png)
  /// native项目图片：图片别名(share_logo_qq.png->shareLogoQq,设置shareLogoQq)
  final String? placeholderAlias;

  /// 当为项目本身工程下图时以相对路径提供,避免部分图片转换Uint8List失败问题
  final bool isProjectImage;

  /// 扩展数据,在buildUrlCall回调参数中返回
  final ImageExtensionData? extensionData;

  /// 构建url回调函数与urlOrAlias互斥
  final OnBuildImageUrlCall? buildUrlCall;

  /// 图片控件构建结束回调
  final OnBuildFinishedCall? buildFinishedCall;

  const ImageWidget(
      {Key? key,
      required this.urlOrAlias,
      this.backgroundColor,
      this.width,
      this.height,
      this.fit,
      this.borderRadius,
      this.placeholder,
      this.placeholderAlias,
      this.isProjectImage = false,
      this.extensionData,
      this.buildUrlCall,
      this.buildFinishedCall})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageWidgetState();
}

class _ImageLoadProvider {
  _ImageLoadProvider._();

  static Widget loadAssetImage(String image, BorderRadius? borderRadius, BoxFit fit, double width, double height) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          image,
          fit: fit,
          width: width,
          height: height,
        ),
      );
    } else {
      return Image.asset(
        image,
        fit: fit,
        width: width,
        height: height,
      );
    }
  }

  static Widget nativeImage(String imageName, String suffix, double width, double height, Color backgroundColor,
      BorderRadius borderRadius, BoxFit fit) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        image: DecorationImage(
          image: NativeImageProvider(imageName: imageName, suffix: suffix, isByte: Platform.isAndroid ? false : true),
          fit: fit,
        ),
      ), // 通过 container 实现圆角
    );
  }

  static Widget mp4Image(String imageName, String suffix, double width, double height, Color backgroundColor,
      BorderRadius borderRadius, BoxFit fit) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        image: DecorationImage(
          image: Mp4ImageProvider(imageName: imageName, suffix: suffix),
          fit: fit,
        ),
      ), // 通过 container 实现圆角
    );
  }

  static Widget loadImage(String image, double? width, double? height, BoxFit fit, BorderRadius? borderRadius,
      Color backgroundColor, OnImageWidgetConfig? imageConfig) {
    if (borderRadius == null) {
      var cacheKey = image.generateMd5();
      return CachedNetworkImage(
        imageUrl: image,
        width: width,
        height: height,
        cacheKey: cacheKey,
        cacheManager: ImageCacheManager.instance,
        placeholder: (BuildContext context, String url) {
          double thumbnailWidth = ((width == null || width < 80) ? 80 : (width / 5.0));
          double thumbnailHeight = (((height ?? 0) < 80) ? 0 : ((height ?? 0) / 5.0));
          return Image.asset(
            imageConfig?.onDefaultImage() ?? "",
            width: thumbnailWidth,
            height: thumbnailHeight,
          );
        },
      );
    } else {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          image: DecorationImage(
            image: CachedImageProvider.imageProvider(url: image),
            fit: fit,
          ),
        ), // 通过 container 实现圆角
      );
    }
  }

  static Widget loadLocalImage(String imageAlias, double width, double height, BoxFit fit, BorderRadius borderRadius,
      Color backgroundColor, bool isProjectImage, OnImageWidgetConfig? imageConfig) {
    var imageFactory = ConfigManager.instance.getConfig(ImageKey.imageListKey);
    if (imageFactory is! ImageListFactory) {
      return loadAssetImage(imageAlias, borderRadius, fit, width, height);
    }
    ImageListFactory imageListFactory = imageFactory;
    String alias = imageAlias.withoutExtension;
    ImageResponse? response = imageListFactory.getFlutterImageResponse(alias);
    if (response == null) {
      response = imageListFactory.getNativeImageResponse(alias);
      if (response == null) {
        return loadAssetImage(imageConfig?.onDefaultImage() ?? "", borderRadius, fit, width, height);
      }
      return nativeImage(
          response.result ?? "", response.suffix ?? "", width, height, backgroundColor, borderRadius, fit);
    } else {
      if (isProjectImage) {
        return loadAssetImage(response.relative ?? "", borderRadius, fit, width, height);
      } else {
        return loadAssetImage(response.result ?? "", borderRadius, fit, width, height);
      }
    }
  }
}

class _ImageWidgetState extends State<ImageWidget> with ImageController {
  String? _urlOrAlias;
  static OnImageWidgetConfig? imageConfig;

  @override
  void initState() {
    super.initState();
    if (widget.buildFinishedCall != null) {
      widget.buildFinishedCall!(this);
    }
    if (widget.buildUrlCall == null) {
      _urlOrAlias = widget.urlOrAlias;
    } else {
      _urlOrAlias = widget.buildUrlCall!(widget.extensionData ?? ImageExtensionData());
    }
  }

  bool _hasProtocol(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  bool _hasMp4(String url) {
    var index = url.indexOf("?");
    if (index > 0) {
      var rawUrl = url.substring(0, index);
      return rawUrl.endsWith(".mp4");
    }
    return url.endsWith(".mp4");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buildUrlCall == null) {
      _urlOrAlias = widget.urlOrAlias;
    }
    try {
      if (_hasProtocol(_urlOrAlias ?? "")) {
        if (_hasMp4(_urlOrAlias ?? "")) {
          return _ImageLoadProvider.mp4Image(
              _urlOrAlias ?? "",
              "mp4",
              widget.width ?? 0,
              widget.height ?? 0,
              widget.backgroundColor ?? Colors.transparent,
              widget.borderRadius ?? BorderRadius.zero,
              widget.fit ?? BoxFit.cover);
        } else {
          OnImageWidgetConfig? imageConfig = getImageConfig();
          return _ImageLoadProvider.loadImage(
              _urlOrAlias ?? "",
              widget.width,
              widget.height,
              widget.fit ?? BoxFit.cover,
              widget.borderRadius,
              widget.backgroundColor ?? Colors.transparent,
              imageConfig);
        }
      }
      OnImageWidgetConfig? imageConfig = getImageConfig();
      return _ImageLoadProvider.loadLocalImage(
          _urlOrAlias ?? "",
          widget.width ?? 0,
          widget.height ?? 0,
          widget.fit ?? BoxFit.cover,
          widget.borderRadius ?? BorderRadius.zero,
          widget.backgroundColor ?? Colors.transparent,
          widget.isProjectImage,
          imageConfig);
    } catch (e) {
      var imageConfig = getImageConfig();
      return _ImageLoadProvider.loadAssetImage(imageConfig?.onDefaultImage() ?? "", widget.borderRadius,
          widget.fit ?? BoxFit.cover, widget.width ?? 0, widget.height ?? 0);
    }
  }

  static OnImageWidgetConfig? getImageConfig() {
    if (imageConfig == null) {
      var configObj = ConfigManager.instance.getConfig(ImageKey.imageConfigKey);
      if (configObj is! OnImageWidgetConfig) {
        imageConfig = _ImageDefaultConfig();
        return imageConfig;
      }
      imageConfig = configObj;
    }
    return imageConfig;
  }

  @override
  void notifyUpdate(String urlOrAlias) {
    if (urlOrAlias.isEmptyString) {
      return;
    }
    setState(() {
      _urlOrAlias = urlOrAlias;
    });
  }
}

class _ImageDefaultConfig with OnImageWidgetConfig {
  @override
  String onDefaultImage() {
    return "packages/cloud_basic_images/assets/2.0x/def_image.png";
  }

  @override
  String onFailureImage() {
    return "packages/cloud_basic_images/assets/2.0x/def_image.png";
  }
}

class ImageFactory {
  factory ImageFactory() => _getInstance();

  static ImageFactory get instance => _getInstance();
  static ImageFactory? _instance;

  ImageFactory._internal() {
    _imageConfig = _getImageConfig();
  }

  static ImageFactory _getInstance() {
    return _instance ??= new ImageFactory._internal();
  }

  OnImageWidgetConfig? _imageConfig;

  OnImageWidgetConfig? _getImageConfig() {
    if (_imageConfig == null) {
      var configObj = ConfigManager.instance.getConfig(ImageKey.imageConfigKey);
      if (configObj is! OnImageWidgetConfig) {
        _imageConfig = _ImageDefaultConfig();
        return _imageConfig;
      }
      _imageConfig = configObj;
    }
    return _imageConfig;
  }

  Widget localImage(
      {required String alias,
      double? width,
      double? height,
      BoxFit fit = BoxFit.scaleDown,
      BorderRadius? borderRadius,
      Color? backgroundColor,
      bool isProjectImage = false}) {
    return _ImageLoadProvider.loadLocalImage(alias, width ?? 0, height ?? 0, fit, borderRadius ?? BorderRadius.zero,
        backgroundColor ?? Colors.transparent, isProjectImage, _imageConfig);
  }

  Image asset({required String alias, bool isProjectImage = false}) {
    return Image(
      image: AssetImageProvider.render(alias, isProjectImage: isProjectImage, imageConfig: _imageConfig),
    );
  }
}
