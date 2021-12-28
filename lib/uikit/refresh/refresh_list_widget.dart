import 'package:eyflutter_uikit/uikit/refresh/cus_refresh_controller.dart';
import 'package:eyflutter_uikit/uikit/refresh/indicator/classic_refresh_header.dart';
import 'package:eyflutter_uikit/uikit/refresh/indicator/cus_refresh_footer.dart';
import 'package:eyflutter_uikit/uikit/refresh/refresh_default_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

typedef void OnInitializeCall(CusRefreshController controller);
typedef void OnRefreshCall(CusRefreshController controller);
typedef void OnLoadCall(CusRefreshController controller);

/// 首次加载方式
enum FirstLoadType {
  ///下拉的方式加载
  pull,

  ///自定义视图层的方式显示在列表上
  overlay
}

/// 列表刷新控件
/// [child] 被刷新视图
/// [onInitialize] 初始化回调
/// [onRefresh] 刷新回调
/// [onLoad] 加载回调
/// [enableControlFinishRefresh] true-需要主动调用结束刷新状态,false-自动处理;
/// [enableControlFinishLoad] true-需要主动调用结束加载状态,false-自动处理;
/// [isAutoLoad] true-自动加载首页数据,反之不加载;
/// [firstLoadType] 首次自动加载列表方式
/// [emptyWidget] 空视图
class RefreshListWidget extends StatefulWidget {
  RefreshListWidget(
      {required this.child,
      this.onInitialize,
      this.onRefresh,
      this.onLoad,
      this.enableControlFinishRefresh: true,
      this.enableControlFinishLoad: true,
      this.isAutoLoad: true,
      this.firstLoadType: FirstLoadType.pull,
      this.emptyWidget,
      this.isVisibilityFirstLoadWidget,
      this.footer,
      this.scrollController,
      this.finishLoadCall,
      this.loadIndicatorWidget});

  final Widget child;
  final OnInitializeCall? onInitialize;
  final OnRefreshCall? onRefresh;
  final OnLoadCall? onLoad;
  final bool enableControlFinishRefresh;
  final bool enableControlFinishLoad;
  final bool isAutoLoad;
  final FirstLoadType firstLoadType;
  final Widget? emptyWidget;
  final bool? isVisibilityFirstLoadWidget;
  final Footer? footer;
  final ScrollController? scrollController;
  final OnFinishLoadCall? finishLoadCall;
  final Widget? loadIndicatorWidget;

  @override
  _CSRefreshState createState() => _CSRefreshState();
}

class _CSRefreshState extends State<RefreshListWidget> {
  CusRefreshController? _controller;
  bool isInitialized = false;
  bool _isFooter = true;
  bool _isLoad = false;

  @override
  void initState() {
    _controller = CusRefreshController(finishLoadCall: widget.finishLoadCall);
    isInitialized = false;
    _isLoad = true;
    _isFooter = true;
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var easyRefresh = EasyRefresh(
      child: widget.child,
      enableControlFinishRefresh: widget.enableControlFinishRefresh,
      enableControlFinishLoad: widget.enableControlFinishLoad,
      controller: _controller,
      scrollController: widget.scrollController,
      header: ClassicRefreshHeader().header,
      footer: widget.footer ?? CusRefreshFooter(loadIndicatorWidget: widget.loadIndicatorWidget),
      onRefresh: widget.onRefresh == null
          ? null
          : () async {
              await Future.delayed(Duration(milliseconds: 100), () {
                if (!widget.enableControlFinishRefresh) {
                  widget.onRefresh!(_controller!);
                  _controller?.finishRefresh(success: true);
                } else {
                  widget.onRefresh!(_controller!);
                }
              });
            },
      onLoad: widget.onLoad == null
          ? null
          : _isFooter
              ? () async {
                  await Future.delayed(Duration(milliseconds: 0), () {
                    if (_isLoad) {
                      _isLoad = false;
                      if (!widget.enableControlFinishLoad) {
                        widget.onLoad!(_controller!);
                        _controller?.finishLoad(success: true);
                      } else {
                        widget.onLoad!(_controller!);
                      }
                      _loadingBottomControl();
                    } else {
                      _controller?.finishLoad();
                    }
                  });
                }
              : null,
      firstRefresh: widget.isAutoLoad && widget.firstLoadType == FirstLoadType.overlay,
      firstRefreshWidget:
          (widget.isVisibilityFirstLoadWidget ?? false) ? RefreshDefaultWidget().firstRefreshWidget() : null,
      emptyWidget: widget.emptyWidget,
    );
    if (!isInitialized) {
      isInitialized = true;
      if (widget.onInitialize != null && widget.isAutoLoad && widget.firstLoadType == FirstLoadType.pull) {
        Future.delayed(Duration(milliseconds: 700), () {
          widget.onInitialize!(_controller!);
        });
      }
    }
    return easyRefresh;
  }

  void _loadingBottomControl() {
    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _isFooter = false;
        _isLoad = false;
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {
            _isFooter = true;
            _isLoad = true;
          });
        });
      });
    });
  }
}
