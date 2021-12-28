import 'package:eyflutter_core/kit/parts/config_manager.dart';
import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:eyflutter_uikit/constants/image_key.dart';
import 'package:eyflutter_uikit/uikit/images/beans/image_response.dart';
import 'package:eyflutter_uikit/uikit/images/image_list_factory.dart';
import 'package:eyflutter_uikit/uikit/images/image_widget.dart';
import 'package:flutter/material.dart';

class AssetImageProvider {
  AssetImageProvider._();

  /// 渲染asset图片
  /// [nameOrAlias] 通过名称或别名查找全路径
  /// [isProjectImage] 当为项目本身工程下图时以相对路径提供,避免部分图片转换Uint8List失败问题
  /// [imageConfig] 图片配置对象
  static AssetImage render(String nameOrAlias, {bool isProjectImage = false, OnImageWidgetConfig? imageConfig}) {
    var imageFactory = ConfigManager.instance.getConfig(ImageKey.imageListKey);
    if (imageFactory is! ImageListFactory) {
      return AssetImage(imageConfig?.onDefaultImage() ?? "");
    }
    ImageListFactory imageListFactory = imageFactory;
    String alias = nameOrAlias.withoutExtension;
    ImageResponse? response = imageListFactory.getFlutterImageResponse(alias);
    if (response == null) {
      return AssetImage(imageConfig?.onDefaultImage() ?? "");
    }
    if (isProjectImage) {
      return AssetImage(response.relative ?? "");
    } else {
      return AssetImage(response.result ?? "");
    }
  }
}
