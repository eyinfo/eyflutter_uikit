import 'package:eyflutter_uikit/uikit/refresh/indicator/refresh_header_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class CusRefreshHeader extends Header {
  /// [height] header容器高度
  /// [triggerDistance] 触发刷新最小距离
  /// [completeDuration] 完成后延时时间
  /// [enableHapticFeedback] 是否启用振动反弹
  CusRefreshHeader(
      {double height = 60.0,
      double triggerDistance = 70.0,
      Duration completeDuration = const Duration(seconds: 0),
      bool enableHapticFeedback = false})
      : super(
          extent: height,
          triggerDistance: triggerDistance,
          float: false,
          completeDuration: completeDuration,
          enableInfiniteRefresh: false,
          enableHapticFeedback: enableHapticFeedback,
        );

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    return RefreshHeaderController(context,
        mode: refreshState,
        pulledExtent: pulledExtent,
        refreshTriggerPullDistance: refreshTriggerPullDistance,
        completeDuration: completeDuration,
        success: success,
        noMore: noMore,
        height: extent,
        enableInfiniteRefresh: enableInfiniteRefresh,
        refreshIndicatorExtent: refreshIndicatorExtent);
  }
}
