import 'package:eyflutter_core/kit/parts/config_manager.dart';
import 'package:eyflutter_uikit/uikit/refresh/events/refresh_header_handler.dart';
import 'package:eyflutter_uikit/uikit/refresh/events/refresh_load_handler.dart';

class RefreshInitManager {
  factory RefreshInitManager() => _getInstance();

  static RefreshInitManager get instance => _getInstance();
  static RefreshInitManager _instance;

  RefreshInitManager._internal();

  static RefreshInitManager _getInstance() {
    if (_instance == null) {
      _instance = new RefreshInitManager._internal();
    }
    return _instance;
  }

  String _refreshHeaderKey = "57d4702ae5942d66";

  /// 重置配置
  /// [headerInitHandler] 刷新组件初始化对象
  void resetConfig(dynamic headerInitHandler) {
    if (headerInitHandler == null) {
      return;
    }
    ConfigManager.instance.addConfig(_refreshHeaderKey, headerInitHandler);
  }

  RefreshHeaderHandler headerHandler() {
    var config = ConfigManager.instance.getConfig(_refreshHeaderKey);
    if (config is! RefreshHeaderHandler) {
      return null;
    }
    return config as RefreshHeaderHandler;
  }

  RefreshLoadHandler loadHandler() {
    var config = ConfigManager.instance.getConfig(_refreshHeaderKey);
    if (config is! RefreshLoadHandler) {
      return null;
    }
    return config as RefreshLoadHandler;
  }
}
