import 'package:flutter/material.dart';

enum TabPageStyle {
  /// 带appBar分页选项
  normal,

  /// 隐藏头导航分页选项
  hiddenAppBar,

  /// 吸顶效果分页选项
  suckTop
}

class TabWidget extends Tab {
  /// The text to display as the tab's label.
  ///
  /// Must not be used in combination with [child].
  final String text;

  /// The widget to be used as the tab's label.
  ///
  /// Usually a [Text] widget, possibly wrapped in a [Semantics] widget.
  ///
  /// Must not be used in combination with [text].
  final Widget child;

  /// An icon to display as the tab's label.
  final Widget icon;

  /// The margin added around the tab's icon.
  ///
  /// Only useful when used in combination with [icon], and either one of
  /// [text] or [child] is non-null.
  final EdgeInsetsGeometry iconMargin;

  /// 扩展数据
  final dynamic extra;

  TabWidget(
      {Key key, this.text, this.child, this.icon, this.iconMargin, this.extra})
      : super(
            key: key,
            text: text,
            child: child,
            icon: icon,
            iconMargin: iconMargin);
}
