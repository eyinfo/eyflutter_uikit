import 'dart:io';
import 'dart:ui';

import 'package:eyflutter_core/lang/lang_storage.dart';
import 'package:eyflutter_core/log/beans/crash_info.dart';
import 'package:eyflutter_core/log/exception/crash_handler.dart';
import 'package:eyflutter_core/log/logger.dart';
import 'package:eyflutter_uikit/enums/screen_orientation.dart';
import 'package:eyflutter_uikit/handler/log_handler.dart';
import 'package:eyflutter_uikit/utils/media_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// flutter engine initialize
mixin OnInitializeListener {
  /// 构建应用启动组件
  Widget buildAppWidget(String defaultRout);

  /// 应用启动回调(组件创建之前执行)
  Future<void> startSyncCall();

  /// 应用启动回调(组件创建后执行)
  void startCall();

  /// 获取应用环境
  int environment();

  /// crash 上报回调
  void crashReportCall(CrashInfo crashInfo) {}

  /// crash 执行完成回调
  void crashCompletedCall();
}

class FlutterInitialize {
  factory FlutterInitialize() => _getInstance();

  static FlutterInitialize get instance => _getInstance();
  static FlutterInitialize _instance;

  FlutterInitialize._internal();

  static FlutterInitialize _getInstance() {
    _instance ??= FlutterInitialize._internal();
    return _instance;
  }

  /// flutter engine 启动初始化
  void start({@required OnInitializeListener listener}) async {
    WidgetsFlutterBinding.ensureInitialized();
    Logger.instance.builder.setLogListener(LogHandler()).setPrintLog(true);
    await listener?.startSyncCall();
    var appWidget = listener?.buildAppWidget(window.defaultRouteName ?? "/");
    CrashHandler.instance.build(appWidget,
        report: (crashInfo) {
          listener?.crashReportCall(crashInfo);
        },
        environment: listener?.environment() ?? 0,
        completedCall: () {
          listener?.crashCompletedCall();
        });
    listener?.startCall();
    MediaUtils.instance.initialize(375);
    LangStorage.instance.loadLang();
    overlayStyle();
  }

  void overlayStyle() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    }
    MediaUtils.instance.screen(ScreenOrientation.portrait);
  }
}
