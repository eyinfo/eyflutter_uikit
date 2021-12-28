import 'package:eyflutter_uikit/uikit/refresh/cus_refresh_controller.dart';
import 'package:eyflutter_uikit/uikit/refresh/refresh_list_widget.dart';
import 'package:eyflutter_uikit/uikit/refresh/refresh_sliver_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

enum RefreshListStyle {
  /// 列表视图
  list,

  /// 任意自定义视图
  custom,
}

class RefreshWidget extends StatefulWidget {
  /// 列表样式
  final RefreshListStyle listStyle;

  /// 刷新对象视图
  final Widget child;

  /// 刷新回调
  final OnRefreshCall? onRefresh;

  /// 加载回调
  final OnLoadCall? onLoad;

  /// 启用刷新功能
  final bool enableRefresh;

  /// 启用加载功能
  final bool enableLoad;

  /// 空视图
  final Widget? emptyWidget;

  /// 是否显示首次加载效果(默认显示)
  final bool isVisibilityFirstLoadWidget;

  ///  true-需要主动调用结束刷新状态,false-自动处理;
  final bool enableControlFinishRefresh;

  /// 底部组件
  final Footer? footer;

  final RefreshInitCall? initCall;

  /// 滚动超过最大比例加载下一页数据(范围：0~1)
  final double scrollMaxRatioLoad;

  /// 加载指示器组件
  final Widget? loadIndicatorWidget;

  const RefreshWidget(
      {Key? key,
      this.listStyle = RefreshListStyle.list,
      required this.child,
      this.onRefresh,
      this.onLoad,
      this.enableRefresh = true,
      this.enableLoad = true,
      this.emptyWidget,
      this.isVisibilityFirstLoadWidget = true,
      this.enableControlFinishRefresh = true,
      this.footer,
      this.initCall,
      this.scrollMaxRatioLoad = 0.7,
      this.loadIndicatorWidget})
      : super(key: key);

  @override
  _RefreshWidgetState createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  CusRefreshController? _refreshController;

  @override
  void initState() {
    super.initState();
    if (widget.enableLoad) {
      scrollController.addListener(() {
        if (_refreshController?.isAutoTriggerLoad ?? false) {
          var scrollPosition = scrollController.position;
          var accounted = scrollPosition.pixels / scrollPosition.maxScrollExtent;
          if (accounted >= widget.scrollMaxRatioLoad) {
            if (widget.onLoad != null && !isLoading) {
              isLoading = true;
              widget.onLoad!(_refreshController!);
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listStyle == RefreshListStyle.custom) {
      return RefreshSliverWidget(
        child: widget.child,
        enableRefresh: widget.enableRefresh,
        enableLoad: widget.enableLoad,
        onRefresh: (controller) {
          _refreshController?.isAutoTriggerLoad = true;
          if (widget.onRefresh != null) {
            widget.onRefresh!(controller);
          }
        },
        onLoad: widget.enableLoad
            ? (controller) {
                if (widget.onLoad != null && !isLoading) {
                  isLoading = true;
                  widget.onLoad!(controller);
                }
              }
            : null,
        emptyWidget: widget.emptyWidget,
        isVisibilityFirstLoadWidget: widget.isVisibilityFirstLoadWidget,
        footer: widget.footer,
        initCall: (CusRefreshController controller) {
          _refreshController = controller;
          if (widget.initCall != null) {
            widget.initCall!(controller);
          }
        },
        scrollController: scrollController,
        finishLoadCall: () => isLoading = false,
        loadIndicatorWidget: widget.loadIndicatorWidget,
      );
    } else {
      return RefreshListWidget(
        child: widget.child,
        firstLoadType: FirstLoadType.overlay,
        onInitialize: (CusRefreshController controller) {
          _refreshController = controller;
          if (widget.initCall != null) {
            widget.initCall!(controller);
          }
          controller.callRefresh();
        },
        onRefresh: widget.enableRefresh ? widget.onRefresh : null,
        onLoad: widget.enableLoad
            ? (controller) {
                if (widget.onLoad != null && !isLoading) {
                  isLoading = true;
                  widget.onLoad!(controller);
                }
              }
            : null,
        emptyWidget: widget.emptyWidget,
        isVisibilityFirstLoadWidget: widget.isVisibilityFirstLoadWidget,
        enableControlFinishRefresh: widget.enableControlFinishRefresh,
        footer: widget.footer,
        scrollController: scrollController,
        finishLoadCall: () => isLoading = false,
        loadIndicatorWidget: widget.loadIndicatorWidget,
      );
    }
  }
}
