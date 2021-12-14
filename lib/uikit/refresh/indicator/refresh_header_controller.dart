import 'package:eyflutter_uikit/uikit/refresh/refresh_init_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class RefreshHeaderController extends StatefulWidget {
  RefreshHeaderController(this.context,
      {this.mode,
      this.pulledExtent,
      this.refreshTriggerPullDistance,
      this.completeDuration,
      this.success,
      this.noMore,
      this.height,
      this.enableInfiniteRefresh,
      this.refreshIndicatorExtent});

  final BuildContext context;
  final RefreshMode mode;
  final double pulledExtent;
  final double refreshTriggerPullDistance;
  final Duration completeDuration;
  final double height;
  final bool enableInfiniteRefresh;
  final double refreshIndicatorExtent;

  //是否刷新成功
  final bool success;

  //true-已经没有数据了;false-还有其它数据;
  final bool noMore;

  @override
  State<StatefulWidget> createState() => _RefreshHeaderControllerState();
}

class _RefreshHeaderControllerState extends State<RefreshHeaderController> {
  // 是否到达触发刷新距离
  bool _overTriggerDistance = false;

  // 是否刷新完成
  bool _refreshFinish = false;
  bool _isShowIndicator = true;

  bool get overTriggerDistance => _overTriggerDistance;

  set overTriggerDistance(bool over) {
    if (_overTriggerDistance != over) {
      _overTriggerDistance = over;
    }
  }

  set refreshFinish(bool finish) {
    if (_refreshFinish != finish) {
      if (finish) {
        Future.delayed(widget.completeDuration, () {
          _refreshFinish = false;
        });
      }
      _refreshFinish = finish;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 是否到达触发刷新距离
    overTriggerDistance =
        widget.mode != RefreshMode.inactive && widget.pulledExtent >= widget.refreshTriggerPullDistance;
    if (widget.mode == RefreshMode.refreshed) {
      refreshFinish = true;
    }
    _isShowIndicator = (widget.mode == RefreshMode.done || widget.mode == RefreshMode.inactive) ? false : true;

    var size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    final double width = (screenWidth - 28);

    return Container(
//      color: Color(0xfff6f6f6),
      height: widget.refreshIndicatorExtent > widget.pulledExtent ? widget.refreshIndicatorExtent : widget.pulledExtent,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Offstage(
              offstage: !_isShowIndicator,
              child: CupertinoActivityIndicator(
                radius: 10,
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: width,
            ),
            child: Text(
              _showText,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  letterSpacing: 0.82,
                  color: Color(RefreshInitManager.instance.headerHandler().headerTextColor() ?? 0xff666666),
                  decoration: TextDecoration.none,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String get _finishedText {
    if (!widget.success) {
      return RefreshInitManager.instance.headerHandler().refreshFailedText();
    }
    return RefreshInitManager.instance.headerHandler().completeText();
  }

  String get _showText {
    if (widget.enableInfiniteRefresh) {
      if (widget.mode == RefreshMode.refreshed ||
          widget.mode == RefreshMode.inactive ||
          widget.mode == RefreshMode.drag) {
        return _finishedText;
      } else {
        return RefreshInitManager.instance.headerHandler().refreshingText();
      }
    }
    switch (widget.mode) {
      case RefreshMode.refresh:
      case RefreshMode.armed:
        return RefreshInitManager.instance.headerHandler().refreshingText();
      case RefreshMode.refreshed:
        return _finishedText;
      case RefreshMode.done:
        return _finishedText;
      default:
        if (overTriggerDistance) {
          return RefreshInitManager.instance.headerHandler().releaseText();
        } else {
          return RefreshInitManager.instance.headerHandler().idleText();
        }
    }
  }
}
