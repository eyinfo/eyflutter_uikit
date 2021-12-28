import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:eyflutter_core/mq/cloud_channel_manager.dart';
import 'package:eyflutter_uikit/uikit/ring/icon_ring_indicator.dart';
import 'package:eyflutter_uikit/uikit/ring/overlay_loading_builder.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'cs_loading_container.dart';

/// loading类型
enum LoadingStyle {
  /// 视图层loading,以该方式显示的loading不影响其它视图的操作
  overlay,

  /// 不同视图显示的loading互相不影响
  aloneOverlay,

  /// 全局loading,以该方式显示的loading会覆盖到整个页面只有销毁后才能操作其它视图
  global
}

class _OverlayLoadingEntry {
  OverlayLoadingBuilder? overlayLoadingBuilder;
  bool? isShow;
}

/// 加载框
class Loadings {
  factory Loadings() => _getInstance();

  static Loadings get instance => _getInstance();
  static Loadings? _instance;

  static Loadings _getInstance() {
    return _instance ??= new Loadings._internal();
  }

  Loadings._internal();

  bool _isGlobal = false;
  bool _isShow = false;
  OverlayLoadingBuilder? _overlayLoadingBuilder;
  BuildContext? _context;

  //style==LoadingStyle.aloneOverlay时有用
  Map<String, _OverlayLoadingEntry> overlayLoadingMap = {};

  /// 设置loadings回调
  void setLoadingsMethodCall({required BuildContext context}) {
    CloudChannelManager.instance.channel?.setMethodCallHandler((call) {
      _nativeLoadingsHandler(call, context);
      return Future.value();
    });
  }

  void _nativeLoadingsHandler(MethodCall call, BuildContext context) {
    if (call.method == "60446828bfba8fd6" && (call.arguments is String)) {
      //show loading
      String message = call.arguments as String;
      this.show(context, text: message);
    } else if (call.method == "44145e78050cd4cf" && (call.arguments is String)) {
      //dismiss loading
      String overlayKey = call.arguments as String;
      this.dismiss(overlayKey: overlayKey);
    }
  }

  /// 显示loading
  /// [context] widget context
  /// [style] loading渲染方式
  /// [type] 加载类型(设置该类型显示加载的不同样式)
  /// [overlayKey] 当前style==LoadingStyle.aloneOverlay时，该为必填项用于区分不同loading视图的标识
  /// [text] 显示文本
  void show(BuildContext context,
      {LoadingStyle style = LoadingStyle.overlay,
      LoadingType type = LoadingType.classic,
      String overlayKey = '',
      String? text}) {
    if (style == LoadingStyle.overlay || style == LoadingStyle.aloneOverlay) {
      _showOverlay(context, text ?? "", type, style == LoadingStyle.aloneOverlay, overlayKey);
    } else if (style == LoadingStyle.global) {
      _isGlobal = true;
      _showGlobal(context, text ?? "", type);
    }
  }

  /// 显示loading
  /// [context] widget context
  /// [style] loading渲染方式
  /// [type] 加载类型(设置该类型显示加载的不同样式)
  /// [overlayKey] 当前style==LoadingStyle.aloneOverlay时，该为必填项用于区分不同loading视图的标识
  /// [text] 显示文本
  /// [Duration] 持续时间
  /// [complete] 完成回调
  void showAutoHidden(BuildContext context,
      {LoadingStyle style = LoadingStyle.overlay,
      LoadingType type = LoadingType.classic,
      String overlayKey = '',
      String? text,
      Duration duration = const Duration(seconds: 2),
      void Function()? complete}) {
    show(context, style: style, type: type, overlayKey: overlayKey, text: text);
    Future.delayed(duration, () {
      _instance?.dismiss();
      if (complete != null) {
        complete();
      }
    });
  }

  /// 销毁loading
  /// [overlayKey] 对应style==LoadingStyle.aloneOverlay loading
  void dismiss({String? overlayKey}) {
    if (overlayKey.isEmptyString) {
      _dismissOverlay();
    } else {
      _dismissOverlayByEntry(overlayKey);
    }
    _dismissGlobal();
    _isShow = false;
    _context = null;
  }

  /// 销毁所有loading
  void dismissAll() {
    if (_isGlobal || _overlayLoadingBuilder != null) {
      dismiss();
    } else {
      overlayLoadingMap.forEach((key, value) {
        value.overlayLoadingBuilder?.dismiss(animation: false);
        value.isShow = false;
      });
      overlayLoadingMap.clear();
    }
  }

  /// loading是否显示中
  bool get isShowing => _isShow;

  void _dismissGlobal() {
    if (_isGlobal && _isShow) {
      _isGlobal = false;
      Navigator.of(_context!).pop();
    }
  }

  void _showGlobal(BuildContext context, String text, LoadingType loadingType) {
    if (_isShow) {
      return;
    }
    _context = context;
    _isShow = true;
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
          var ringIndicator = IconRingIndicator(
            size: 20,
            indicatorBackgroundColor: Color(0xffb5bdc8),
            indicatorColor: Color(0xffe2e5e9),
            loadingType: loadingType,
          );
          return CsLoadingContainer(
            text: text,
            indicator: ringIndicator,
            animation: true,
          );
        }).then((value) {
      _isShow = false;
      _context = null;
      _isGlobal = false;
    });
  }

  void _showOverlay(
      BuildContext context, String text, LoadingType loadingType, bool isAloneOverlay, String overlayKey) {
    bool isAlone = (isAloneOverlay && overlayKey.isNotEmptyString);
    if (!isAlone) {
      //最好先销毁上一个loading,否则如果列表条目中有loading效果且在快速点击时当前操作可能无效;
      dismiss();
    }
    var builder = OverlayLoadingBuilder();
    var ringIndicator = IconRingIndicator(
      size: 42,
      indicatorBackgroundColor: Color(0xffb5bdc8),
      indicatorColor: Color(0xffe2e5e9),
      loadingType: loadingType,
    );
    builder.show(context, text: text, indicator: ringIndicator);
    if (isAlone) {
      var entry = _OverlayLoadingEntry();
      entry.overlayLoadingBuilder = builder;
      entry.isShow = true;
      //销毁相同key的loading
      _dismissOverlayByEntry(overlayKey);
      overlayLoadingMap[overlayKey] = entry;
    } else {
      _overlayLoadingBuilder = builder;
      _isShow = true;
    }
  }

  void _dismissOverlay() {
    _overlayLoadingBuilder?.dismiss(animation: false);
    _overlayLoadingBuilder = null;
  }

  void _dismissOverlayByEntry(String? overlayKey) {
    if (overlayLoadingMap.containsKey(overlayKey)) {
      var remove = overlayLoadingMap.remove(overlayKey);
      remove?.overlayLoadingBuilder?.dismiss(animation: false);
    }
  }
}
