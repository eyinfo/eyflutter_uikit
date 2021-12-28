import 'package:eyflutter_uikit/uikit/refresh/cus_refresh_controller.dart';
import 'package:eyflutter_uikit/uikit/refresh/indicator/classic_refresh_header.dart';
import 'package:eyflutter_uikit/uikit/refresh/indicator/cus_refresh_footer.dart';
import 'package:eyflutter_uikit/uikit/refresh/refresh_default_widget.dart';
import 'package:eyflutter_uikit/uikit/refresh/refresh_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

typedef RefreshInitCall = void Function(CusRefreshController controller);

class RefreshSliverWidget extends StatefulWidget {
  final Widget? child;
  final bool? enableRefresh;
  final bool? enableLoad;
  final OnRefreshCall? onRefresh;
  final OnLoadCall? onLoad;
  final Widget? emptyWidget;
  final bool? isVisibilityFirstLoadWidget;
  final Footer? footer;
  final RefreshInitCall? initCall;
  final ScrollController? scrollController;
  final OnFinishLoadCall? finishLoadCall;
  final Widget? loadIndicatorWidget;

  const RefreshSliverWidget(
      {Key? key,
      this.child,
      this.enableRefresh,
      this.enableLoad,
      this.onRefresh,
      this.onLoad,
      this.emptyWidget,
      this.isVisibilityFirstLoadWidget,
      this.footer,
      this.initCall,
      this.scrollController,
      this.finishLoadCall,
      this.loadIndicatorWidget})
      : super(key: key);

  @override
  _RefreshSliverWidgetState createState() => _RefreshSliverWidgetState();
}

class _RefreshSliverWidgetState extends State<RefreshSliverWidget> {
  CusRefreshController? _controller;

  @override
  void initState() {
    _controller = CusRefreshController(finishLoadCall: widget.finishLoadCall);
    if (widget.initCall != null) {
      widget.initCall!(_controller!);
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      firstRefresh: true,
      enableControlFinishLoad: true,
      bottomBouncing: true,
      header: ClassicRefreshHeader().header,
      footer: widget.footer ?? CusRefreshFooter(loadIndicatorWidget: widget.loadIndicatorWidget),
      controller: _controller,
      scrollController: widget.scrollController,
      emptyWidget: widget.emptyWidget,
      firstRefreshWidget:
          (widget.isVisibilityFirstLoadWidget ?? false) ? RefreshDefaultWidget().firstRefreshWidget() : null,
      slivers: <Widget>[
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return widget.child;
        }, childCount: 1))
      ],
      onRefresh: (widget.enableRefresh ?? false)
          ? () async {
              await Future.delayed(Duration(milliseconds: 100), () {
                if (widget.onRefresh != null) {
                  widget.onRefresh!(_controller!);
                }
              });
            }
          : null,
      onLoad: (widget.enableLoad ?? false)
          ? () async {
              await Future.delayed(Duration(milliseconds: 100), () {
                if (widget.onLoad != null) {
                  widget.onLoad!(_controller!);
                }
              });
            }
          : null,
    );
  }
}
