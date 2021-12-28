import 'dart:async';
import 'dart:collection';

import 'package:eyflutter_core/kit/parts/config_manager.dart';
import 'package:eyflutter_core/kit/utils/map/map_extension.dart';
import 'package:eyflutter_core/kit/utils/set/list_extention.dart';
import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:eyflutter_core/log/logger.dart';
import 'package:eyflutter_core/mq/route/cloud_route_observer.dart';
import 'package:eyflutter_core/mq/route/route_uri_parse.dart';
import 'package:eyflutter_core/storage/memory_utils.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

final LinkedHashSet<String> routeNames = LinkedHashSet();

mixin OnSchemeListener {
  /// 根据scheme跳转
  void onGoScheme(String scheme);
}

mixin OnPageLifecycle {
  void onPreCreate(BuildContext context, String routeName, Map<String, dynamic> arguments) {}

  void onCreate(BuildContext context, String routeName, Map<String, dynamic> arguments) {}

  void onResume(String routeName, Map<String, dynamic> arguments) {}

  void onPause(String routeName, Map<String, dynamic> arguments) {}

  void onDestroy(String routeName, Map<String, dynamic> arguments) {}
}

/// 如果每次切换页面旧页面销毁走State和Route生命周期;如果event触发跳转走eventBus
/// https://img.mukewang.com/5d357d4d0001a7b709601518.png
abstract class LifecycleState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver, RouteAware, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  T get widget => super.widget;

  void onPreCreate(BuildContext context, String routeName, Map<String, dynamic> arguments) {}

  void onCreate(BuildContext context, String routeName, Map<String, dynamic> arguments) {}

  void onResume(String routeName, Map<String, dynamic> arguments) {}

  void onPause(String routeName, Map<String, dynamic> arguments) {}

  void onDestroy(String routeName, Map<String, dynamic> arguments) {}

  //是否在栈顶
  bool _isTop = false;

  //是否销毁
  bool _isDestroy = false;

  //当前路由名
  String? _routeName;
  String? _routePath;

  //当前路由参数
  Map<String, dynamic> _arguments = {};

  //是否已初始化
  bool _isInitialized = false;

  StreamSubscription? _streamSubscription;

  //是否注册uni links key
  String _isRegisterUniLinksKey = "ed74499bb870417e";

  //是否显示软键盘
  bool _isVisibilityKeyboard = false;

  //是否显示软键盘
  bool get visibilityKeyboard => _isVisibilityKeyboard;

  @override
  bool get wantKeepAlive => true;

  OnPageLifecycle? _onPageLifecycle;

  /// 软键盘改变监听
  /// [visibility] true:已显示软键盘;false:已关闭软键盘;
  void onKeyboardChanged(bool visibility) {}

  /// uniLinks支持页面对应的hash code
  List<int> get uniLinksSupportHashCodes => [];

  /// state lifecycle listener
  static String stateLifecycleKey = "d654e2591793e0c7";

  /// scheme listener key
  static String schemeListenerKey = "a7e4d67828da1192";

  //子类重载initState方法时要在super.initState()之后调用
  @override
  void initState() {
    super.initState();
    this._isInitialized = false;
    WidgetsBinding.instance?.addObserver(this);
    if (!(MemoryUtils.instance.getBool(_isRegisterUniLinksKey))) {
      //判断当前页面包括并支持uni links
      if (uniLinksSupportHashCodes.isNotEmptyList && uniLinksSupportHashCodes.contains(this.hashCode)) {
        _registerUniLinks();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _distributionState(state);
    super.didChangeAppLifecycleState(state);
  }

  Map<String, dynamic> get arguments => _arguments;

  void _distributionState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isTop) {
          _isTop = true;
          onResume(_routeName ?? "", _arguments);
          _pageLifecycle?.onResume(_routeName ?? "", _arguments);
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (_isTop && isStackTopRoute()) {
          _isTop = false;
          onPause(_routeName ?? "", _arguments);
          _pageLifecycle?.onPause(_routeName ?? "", _arguments);
        }
        break;
      case AppLifecycleState.detached:
        //与引擎分离
        if (_isRootRoute()) {
          if (_isTop) {
            _isTop = false;
            onPause(_routeName ?? "", _arguments);
            _pageLifecycle?.onPause(_routeName ?? "", _arguments);
          }
          if (!_isDestroy) {
            _isDestroy = true;
            onDestroy(_routeName ?? "", _arguments);
            _pageLifecycle?.onDestroy(_routeName ?? "", _arguments);
            _unBind();
          }
        }
        break;
    }
  }

  //该方法只在didChangeAppLifecycleState调用
  bool isStackTopRoute() {
    var last = routeNames.last;
    var route = ModalRoute.of(context);
    var name = _getPageRouteName(route!);
    var routeTag = '${name}_${this.hashCode}';
    return last == routeTag;
  }

  @override
  void didChangeDependencies() {
    if (!_isInitialized) {
      _isInitialized = true;
      var route = ModalRoute.of(context);
      //添加通知管理
      _routePath = route?.settings.name ?? "";
      //解析参数
      this._routeName = _getPageRouteName(route!);
      var arguments = route.settings.arguments;
      if (arguments is RouteUriParse) {
        RouteUriParse routerUrlParse = arguments;
        this._arguments.addAll(routerUrlParse.queryParameters);
      } else if (arguments is LinkedHashMap<String, dynamic>) {
        this._arguments.addAll(arguments);
      }
      routeNames.add('${_routeName}_${this.hashCode}');
      _isTop = true;
      _isDestroy = false;
      onPreCreate(context, _routeName ?? "", _arguments);
      _pageLifecycle?.onPreCreate(context, _routeName ?? "", _arguments);
      Future.delayed(Duration.zero, () {
        onCreate(context, _routeName ?? "", _arguments);
        _pageLifecycle?.onCreate(context, _routeName ?? "", _arguments);
        onResume(_routeName ?? "", _arguments);
        _pageLifecycle?.onResume(_routeName ?? "", _arguments);
        FocusScope.of(context).requestFocus(new FocusNode());
      });
    }
    super.didChangeDependencies();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _isVisibilityKeyboard = MediaQuery.of(context).viewInsets.bottom > 0;
        onKeyboardChanged(_isVisibilityKeyboard);
      });
    });
  }

  /// 获取路由参数
  /// [key] 参数key
  /// [defaultValue] 参数默认值
  dynamic getArgument(String key, {dynamic defaultValue}) {
    if (key.isEmptyString || !_arguments.containsKey(key)) {
      return null;
    }
    return _arguments.getValue(key, defaultValue);
  }

  String _getPageRouteName(ModalRoute route) {
    var settings = route.settings;
    return settings.name ?? "";
  }

  bool _isRootRoute() {
    return _routeName == '/';
  }

  @override
  void didPush() {
    if (!_isTop) {
      _isTop = true;
      onResume(_routeName ?? "", _arguments);
      _pageLifecycle?.onResume(_routeName ?? "", _arguments);
    }
    super.didPush();
  }

  @override
  void didPushNext() {
    if (_isTop) {
      _isTop = false;
      onPause(_routeName ?? "", _arguments);
      _pageLifecycle?.onPause(_routeName ?? "", _arguments);
    }
    super.didPushNext();
  }

  @override
  void didPop() {
    if (_isTop) {
      _isTop = false;
      onPause(_routeName ?? "", _arguments);
      _pageLifecycle?.onPause(_routeName ?? "", _arguments);
    }
    super.didPop();
  }

  @override
  void didPopNext() {
    if (!_isTop) {
      _isTop = true;
      onResume(_routeName ?? "", _arguments);
      _pageLifecycle?.onResume(_routeName ?? "", _arguments);
    }
    super.didPopNext();
  }

  @override
  void dispose() {
    if (_isTop) {
      _isTop = false;
      onPause(_routeName ?? "", _arguments);
      _pageLifecycle?.onPause(_routeName ?? "", _arguments);
    }
    if (!_isDestroy) {
      _isDestroy = true;
      onDestroy(_routeName ?? "", _arguments);
      _pageLifecycle?.onDestroy(_routeName ?? "", _arguments);
      _unBind();
    }
    _streamSubscription?.cancel();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void _unBind() {
    //移除状态通知监听
    CloudRouteObserver.instance.removeNotification(_routePath ?? "");
    //注册状态绑定
    _isInitialized = false;
    routeNames.remove('${_routeName}_${this.hashCode}');
    MemoryUtils.instance.set(_isRegisterUniLinksKey, false);
  }

  /// 注册scheme对象
  void _registerUniLinks() async {
    try {
      MemoryUtils.instance.set(_isRegisterUniLinksKey, true);
      //app未打开
      var initialLink = getInitialLink();
      initialLink.then((String? link) {
        if (link.isNotEmptyString) {
          _schemeHandler(link!);
        }
      });
      //app已打开
      _streamSubscription = linkStream.listen((String? link) {
        if (!mounted || link.isEmptyString) {
          return;
        }
        _schemeHandler(link!);
      }, onError: (Object error) {
        if (!mounted) {
          return;
        }
      });
    } catch (e) {
      Logger.instance.error(e);
    }
  }

  void _schemeHandler(String link) {
    try {
      var config = ConfigManager.instance.getConfig(schemeListenerKey);
      if (config == null || config is! OnSchemeListener) {
        return;
      }
      var schemeListener = config;
      schemeListener.onGoScheme(link);
    } catch (e) {
      Logger.instance.error(e);
    }
  }

  OnPageLifecycle? get _pageLifecycle {
    if (_onPageLifecycle != null) {
      return _onPageLifecycle;
    }
    var config = ConfigManager.instance.getConfig(stateLifecycleKey);
    if (config == null || config is! OnPageLifecycle) {
      return null;
    }
    _onPageLifecycle = config;
    return _onPageLifecycle;
  }
}
