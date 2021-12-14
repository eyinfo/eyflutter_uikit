import 'package:flutter/material.dart';

/// 滑动视图超出继续滑动时效果
class OverScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    var _platform = getPlatform(context);
    if (_platform == TargetPlatform.android ||
        _platform == TargetPlatform.fuchsia) {
      return GlowingOverscrollIndicator(
        child: child,
        //不显示头部水波纹
        showLeading: false,
        //不显示尾部水波纹
        showTrailing: false,
        axisDirection: axisDirection,
        color: Theme.of(context).accentColor,
      );
    } else {
      return child;
    }
  }
}
