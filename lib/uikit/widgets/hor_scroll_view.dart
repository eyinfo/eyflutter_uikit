import 'dart:collection';

import 'package:eyflutter_uikit/uikit/over_scroll_behavior.dart';
import 'package:flutter/material.dart';

class ItemViewBuilder {
  ItemViewBuilder({this.height, this.backgroundColor, this.children = const <Widget>[], this.rowPadding});

  /// 条目视图高度
  final double? height;

  /// 条目背景颜色
  final Color? backgroundColor;

  /// 子视图
  final List<Widget> children;

  /// 行边距
  final EdgeInsetsGeometry? rowPadding;
}

/// 横向滑动视图
class HorScrollView extends StatelessWidget {
  HorScrollView(
      {this.topContainer,
      this.children = const <ItemViewBuilder>[],
      this.bottomContainer,
      this.dividerWidth,
      this.dividerColor,
      this.horDividerHeight,
      this.horDividerColor,
      this.backgroundColor,
      this.rowPadding});

  /// 头部视图
  final Widget? topContainer;

  final List<ItemViewBuilder> children;

  /// 底部视图
  final Widget? bottomContainer;

  /// 分隔线宽度
  final double? dividerWidth;

  /// 分隔线颜色
  final Color? dividerColor;

  /// 横向分隔线高度
  final double? horDividerHeight;

  /// 横向分隔线颜色
  final Color? horDividerColor;

  /// 背景颜色
  final Color? backgroundColor;

  /// 行边距
  final EdgeInsetsGeometry? rowPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _buildViews(children),
    );
  }

  Column _buildViews(List<ItemViewBuilder> children) {
    List<Widget> rows = [this.topContainer ?? Container()];
    LinkedHashSet<Widget> widgets = new LinkedHashSet();
    var count = children.length;
    children.forEach((ItemViewBuilder builder) {
      var index = children.indexOf(builder);
      widgets.add(_buildRowView(backgroundColor ?? Colors.white,
          rowPadding ?? EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0), builder));
      if (((index + 1) < count)) {
        widgets.add(Container(
          height: horDividerHeight ?? 0,
          color: horDividerColor ?? Colors.transparent,
        ));
      }
    });
    rows.addAll(widgets);
    rows.add(bottomContainer ?? Container());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  Container _buildRowView(Color backgroundColor, EdgeInsetsGeometry rowPadding, ItemViewBuilder builder) {
    return Container(
      height: builder.height ?? 0,
      color: (builder.backgroundColor ?? backgroundColor),
      padding: (builder.rowPadding ?? rowPadding),
      child: ScrollConfiguration(
        behavior: OverScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: builder.children.length,
          separatorBuilder: (context, index) {
            return Container(
              width: this.dividerWidth ?? 0,
              color: this.dividerColor ?? Colors.white,
            );
          },
          itemBuilder: (context, index) {
            return builder.children[index];
          },
        ),
      ),
    );
  }
}
