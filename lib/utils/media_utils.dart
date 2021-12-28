import 'dart:ui';

import 'package:eyflutter_uikit/enums/screen_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MediaUtils {
  factory MediaUtils() => _getInstance();

  static MediaUtils get instance => _getInstance();
  static MediaUtils? _instance;

  MediaUtils._internal();

  static MediaUtils _getInstance() {
    return _instance ??= new MediaUtils._internal();
  }

  Size? _size;
  double? _pixelRatio;
  double? _statusBarHeight;
  double? _bottomBarHeight;
  double _designWidth = 0;
  BuildContext? _context;

  ///强制竖屏
  ///[orientation]当前屏幕方向
  void screen(ScreenOrientation orientation) {
    if (orientation == ScreenOrientation.landscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else if (orientation == ScreenOrientation.portrait) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  /// 应用启动时调用
  /// [designWidth] 设计搞宽度
  void initialize(double designWidth) {
    _designWidth = designWidth;
  }

  /// 保存material上下文
  void setContext(BuildContext context) {
    this._context = context;
  }

  /// 返回全局material上下文
  BuildContext? get context => _context;

  Size get _getSize {
    if (_size == null) {
      _size = window.physicalSize;
    }
    return _size ?? Size.zero;
  }

  /// 屏幕宽度
  double get screenWidth => _getSize.width / pixelRatio;

  /// 屏幕高度
  double get screenHeight => _getSize.height / pixelRatio;

  /// 屏幕像素宽度
  double get screenPixelWidth => _getSize.width;

  /// 屏幕像素高度
  double get screenPixelHeight => _getSize.height;

  /// 设备的像素密度
  double get pixelRatio {
    if (_pixelRatio == null || _pixelRatio == 0) {
      _pixelRatio = window.devicePixelRatio;
    }
    return _pixelRatio ?? 0;
  }

  /// 状态栏高度 dp 刘海屏会更高
  double get statusBarHeight {
    if (_statusBarHeight == null || _statusBarHeight == 0) {
      _statusBarHeight = window.padding.top;
    }
    return (_statusBarHeight ?? 0) / pixelRatio;
  }

  /// 底部安全区距离 dp
  double get bottomBarHeight {
    if (_bottomBarHeight == null || _bottomBarHeight == 0) {
      _bottomBarHeight = window.padding.bottom;
    }
    return (_bottomBarHeight ?? 0) / pixelRatio;
  }

  /// 屏幕尺寸比例
  double get sizeScale {
    if (_designWidth <= 0) {
      return 1;
    }
    return screenWidth / _designWidth;
  }

  /// 实际宽度
  /// [designWidth] 设计搞宽度
  double width(double designWidth) {
    return designWidth * sizeScale;
  }

  /// 实际高度
  /// [designHeight] 设计搞高度
  double height(double designHeight) {
    return designHeight * sizeScale;
  }

  /// 字体大小适配
  double sp(double fontSize) => fontSize * sizeScale;
}
