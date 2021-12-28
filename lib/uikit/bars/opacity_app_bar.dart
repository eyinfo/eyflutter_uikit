import 'dart:ui';

import 'package:flutter/material.dart';

mixin OpacityAppBarOption {
  void updateOpacity(double opacity);

  double getAppBarHeight();
}

typedef OpacityAppBarCall(OpacityAppBarOption option);

class OpacityAppBar extends StatefulWidget {
  /// app bar listener
  final OpacityAppBarCall? call;

  /// 标题
  final String? title;

  /// app bar 右边按钮
  final List<Widget>? actions;

  const OpacityAppBar({Key? key, this.call, this.title, this.actions}) : super(key: key);

  @override
  _OpacityAppBarState createState() => _OpacityAppBarState();
}

class _OpacityAppBarState extends State<OpacityAppBar> with OpacityAppBarOption {
  double stateHeight = 0;
  double appBarOpacity = 0;

  @override
  void initState() {
    super.initState();
    stateHeight = MediaQueryData.fromWindow(window).padding.top;
    if (widget.call != null) {
      widget.call!(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text(
        widget.title ?? "",
        style: TextStyle(fontSize: 18, color: Color(0xff333333)),
      ),
      centerTitle: true,
      elevation: 0,
      shadowColor: Colors.transparent,
      actions: widget.actions ?? [],
    );
    return Opacity(
      opacity: appBarOpacity,
      child: Container(
        height: kToolbarHeight + stateHeight,
        child: appBar,
      ),
    );
  }

  @override
  void updateOpacity(double opacity) {
    setState(() {
      appBarOpacity = opacity;
    });
  }

  @override
  double getAppBarHeight() {
    return kToolbarHeight + stateHeight;
  }
}
