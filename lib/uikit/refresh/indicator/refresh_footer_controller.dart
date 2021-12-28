import 'package:eyflutter_uikit/uikit/refresh/refresh_init_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class RefreshFooterController extends StatefulWidget {
  RefreshFooterController(
      {this.loadIndicatorExtent,
      this.pulledExtent,
      this.noMore,
      this.enableInfiniteLoad,
      this.mode,
      this.loadTriggerPullDistance,
      this.loadIndicatorWidget});

  final double? loadIndicatorExtent;
  final double? pulledExtent;
  final bool? noMore;
  final bool? enableInfiniteLoad;
  final LoadMode? mode;
  final double? loadTriggerPullDistance;

  //加载指示效果组件
  final Widget? loadIndicatorWidget;

  @override
  _RefreshFooterControllerState createState() => _RefreshFooterControllerState();
}

class _RefreshFooterControllerState extends State<RefreshFooterController> {
  // 是否到达触发加载距离
  bool _overTriggerDistance = false;
  bool _isShowIndicator = true;

  bool get overTriggerDistance => _overTriggerDistance;

  double _footerHeight = 0;

  set overTriggerDistance(bool over) {
    if (_overTriggerDistance != over) {
      _overTriggerDistance = over;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 是否到达触发加载距离
    overTriggerDistance =
        widget.mode != LoadMode.inactive && ((widget.pulledExtent ?? 0) >= (widget.loadTriggerPullDistance ?? 0));
    _isShowIndicator = (widget.mode == LoadMode.done || widget.mode == LoadMode.loaded) ? false : true;
    _footerHeight = (widget.loadIndicatorExtent ?? 0) > (widget.pulledExtent ?? 0)
        ? (widget.loadIndicatorExtent ?? 0)
        : (widget.pulledExtent ?? 0);
    return Container(
      height: _footerHeight,
      child: buildDefaultFooter(),
    );
  }

  Widget buildDefaultFooter() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Offstage(
          offstage: !(_isShowIndicator && widget.loadIndicatorWidget != null),
          child: widget.loadIndicatorWidget ?? Container(),
        ),
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Offstage(
            offstage: !(_isShowIndicator && widget.loadIndicatorWidget == null),
            child: CupertinoActivityIndicator(
              radius: 10,
            ),
          ),
        ),
        Offstage(
          offstage: _isShowIndicator && widget.loadIndicatorWidget != null,
          child: Text(
            _showText,
            textAlign: TextAlign.center,
            style: TextStyle(
                letterSpacing: 0.82,
                color: Color(RefreshInitManager.instance.loadHandler()?.loadTextColor() ?? 0xffffffff),
                decoration: TextDecoration.none,
                fontSize: 14),
          ),
        )
      ],
    );
  }

  String get _showText {
    if (widget.noMore ?? false) {
      return RefreshInitManager.instance.loadHandler()?.noDataText() ?? "";
    }
    // if (widget.enableInfiniteLoad) {
    //   if (widget.mode == LoadMode.done || widget.mode == LoadMode.loaded) {
    //     //widget.mode == LoadMode.drag
    //     return RefreshInitManager.instance.loadHandler().loadCompleteText();
    //   } else {
    //     return RefreshInitManager.instance.loadHandler().loadingText();
    //   }
    // }
    switch (widget.mode) {
      case LoadMode.load:
      case LoadMode.armed:
        return RefreshInitManager.instance.loadHandler()?.loadingText() ?? "";
      case LoadMode.loaded:
      case LoadMode.done:
        return RefreshInitManager.instance.loadHandler()?.loadCompleteText() ?? "";
      default:
        if (overTriggerDistance) {
          return RefreshInitManager.instance.loadHandler()?.loadReleaseText() ?? "";
        } else {
          return RefreshInitManager.instance.loadHandler()?.loadIdleText() ?? "";
        }
    }
  }
}
