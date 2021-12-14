import 'package:eyflutter_core/mq/cloud_channel_manager.dart';

enum ToastGravity {
  TOP,
  CENTER,
  BOTTOM,
}

enum ToastDuration {
  LONG,
  SHORT,
}

class ToastUtils {
  factory ToastUtils() => _getInstance();

  static ToastUtils get instance => _getInstance();
  static ToastUtils _instance;

  ToastUtils._internal();

  static ToastUtils _getInstance() {
    if (_instance == null) {
      _instance = new ToastUtils._internal();
    }
    return _instance;
  }

  String _toastMethodName = "aa94dd6839b29726";

  /// 显示toast提示
  /// [msg] 提示内容
  /// [gravity] 显示位置(即对齐方式)
  /// [duration] 显示
  void show(String msg, {ToastGravity gravity = ToastGravity.CENTER, ToastDuration duration = ToastDuration.LONG}) {
    CloudChannelManager.instance.send(_toastMethodName, arguments: {
      "msg": msg,
      "gravity": gravity.name,
      "duration": duration.name,
    });
  }
}
