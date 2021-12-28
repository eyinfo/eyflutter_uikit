import 'package:eyflutter_uikit/uikit/refresh/indicator/refresh_footer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class CusRefreshFooter extends Footer {
  final Widget? loadIndicatorWidget;

  CusRefreshFooter({this.loadIndicatorWidget});

  @override
  Widget contentBuilder(
      BuildContext context,
      LoadMode loadState,
      double pulledExtent,
      double loadTriggerPullDistance,
      double loadIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration? completeDuration,
      bool enableInfiniteLoad,
      bool success,
      bool noMore) {
    return RefreshFooterController(
      loadIndicatorExtent: loadIndicatorExtent,
      pulledExtent: pulledExtent,
      noMore: noMore,
      enableInfiniteLoad: enableInfiniteLoad,
      mode: loadState,
      loadTriggerPullDistance: loadTriggerPullDistance,
      loadIndicatorWidget: loadIndicatorWidget,
    );
  }
}
