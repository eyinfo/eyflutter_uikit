import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:flutter/material.dart';

typedef SettingBarItemClick = void Function(String tag, dynamic extra);

class SettingBarItem {
  /// 栏目图标
  final Widget icon;

  /// 栏目文本
  final String text;

  /// 栏目二级文本
  final String secondary;

  /// 标注文本(栏目右侧显示)
  final String mark;

  /// 标注图标(栏目右侧显示)
  final Icon markIcon;

  /// 右边图标(markIcon左侧控件)
  final Widget markWidget;

  /// 栏目文本颜色
  final Color textColor;

  /// 文本大小
  final double textSize;

  /// 文本加粗
  final bool textBold;

  /// 栏目二级文本颜色
  final Color secondaryColor;

  /// 栏目二级文本大小
  final double secondarySize;

  /// 栏目二级文本加粗
  final bool secondaryBold;

  /// 栏目二级文本对齐
  final Alignment secondaryAlignment;

  /// 栏目标注文本颜色
  final Color markColor;

  /// 栏目标注文本大小
  final double markSize;

  /// 栏目标注文本加粗
  final bool markBold;

  /// 栏目标识
  final String tag;

  /// 扩展数据
  final dynamic extra;

  const SettingBarItem(
      {this.icon,
      this.text,
      this.secondary,
      this.mark,
      this.markIcon,
      this.markWidget,
      this.textColor,
      this.textSize,
      this.textBold,
      this.secondaryColor,
      this.secondarySize,
      this.secondaryBold,
      this.secondaryAlignment = Alignment.centerLeft,
      this.markColor,
      this.markSize,
      this.markBold,
      this.tag,
      this.extra});
}

class SettingBar extends StatefulWidget {
  /// 配置项集合
  final List<SettingBarItem> items;

  /// 栏目内边距
  final EdgeInsetsGeometry itemPadding;

  /// 栏目图标外边距
  final EdgeInsetsGeometry iconMargin;

  /// 栏目文本内边距
  final EdgeInsetsGeometry textPadding;

  /// 栏目二级文本内边距
  final EdgeInsetsGeometry secondaryPadding;

  /// 栏目标注文本内边距
  final EdgeInsetsGeometry markPadding;

  /// 栏目标注图标外边距
  final EdgeInsetsGeometry markIconMargin;

  /// 栏目文本颜色
  final Color textColor;

  /// 栏目文本大小
  final double textSize;

  /// 栏目文本加粗
  final bool textBold;

  /// 栏目二级文本颜色
  final Color secondaryColor;

  /// 栏目二级文本大小
  final double secondarySize;

  /// 栏目二级文本加粗
  final bool secondaryBold;

  /// 栏目标注文本颜色
  final Color markColor;

  /// 栏目标注文本大小
  final double markSize;

  /// 栏目标注文本加粗
  final bool markBold;

  /// [SettingBar]组件背景颜色
  final Color backgroundColor;

  /// [SettingBar]外边距
  final EdgeInsetsGeometry margin;

  /// [SettingBar]圆角半径(默认8.0)
  final double radius;

  /// [SettingBar]边框颜色
  final Color borderColor;

  /// [SettingBar]边框宽度
  final double borderWidth;

  /// 栏目事件回调
  final SettingBarItemClick itemClick;

  /// 是否显示分割线(默认显示)
  final bool isVisibilityDivider;

  /// 分割线颜色
  final Color dividerColor;

  /// 分割线高度
  final double dividerHeight;

  /// 分割线左右边距
  final EdgeInsetsGeometry dividerPadding;

  const SettingBar(
      {Key key,
      this.items,
      this.itemPadding = const EdgeInsets.only(left: 15, right: 8, top: 10, bottom: 10),
      this.iconMargin = const EdgeInsets.only(right: 8),
      this.textPadding,
      this.secondaryPadding = const EdgeInsets.only(left: 6, right: 6),
      this.markPadding,
      this.markIconMargin,
      this.textColor,
      this.textSize,
      this.textBold,
      this.secondaryColor,
      this.secondarySize,
      this.secondaryBold,
      this.markColor,
      this.markSize,
      this.markBold,
      this.backgroundColor = Colors.white,
      this.margin,
      this.radius = 8.0,
      this.borderColor = const Color(0xffe5e5e5),
      this.borderWidth = 0.8,
      this.itemClick,
      this.isVisibilityDivider = true,
      this.dividerColor = const Color(0xffd1d1d1),
      this.dividerHeight = 1,
      this.dividerPadding = const EdgeInsets.only(left: 10, right: 10)})
      : super(key: key);

  @override
  _SettingBarState createState() => _SettingBarState();
}

class _SettingBarState extends State<SettingBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(widget.radius ?? 8),
          border: new Border.all(color: widget.borderColor ?? Color(0xffe5e5e5), width: widget.borderWidth ?? 0.8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: buildSettingItems(),
      ),
    );
  }

  List<Widget> buildSettingItems() {
    List<Widget> lst = [];
    int index = 0;
    int len = widget.items?.length ?? 0;
    widget.items?.forEach((element) {
      lst.add(buildItem(element));
      if (widget.isVisibilityDivider && (index + 1) < len) {
        lst.add(Padding(
          padding: widget.dividerPadding ?? EdgeInsets.zero,
          child: Divider(
            height: widget.dividerHeight ?? 1,
            color: widget.dividerColor ?? Color(0xffe5e5e5),
          ),
        ));
      }
      index++;
    });
    return lst;
  }

  Widget buildItem(SettingBarItem item) {
    return FlatButton(
        onPressed: () {
          onItemClick(item);
        },
        padding: EdgeInsets.zero,
        child: Padding(
          padding: widget.itemPadding ?? EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: buildItemWidgets(item),
          ),
        ));
  }

  void onItemClick(SettingBarItem item) {
    if (widget.itemClick != null) {
      widget.itemClick(item.tag, item.extra);
    }
  }

  List<Widget> buildItemWidgets(SettingBarItem item) {
    List<Widget> lst = [];
    if (item.icon != null) {
      lst.add(Container(
        margin: widget.iconMargin ?? EdgeInsets.zero,
        child: item.icon,
      ));
    }
    if (item.text.isNotEmptyString) {
      lst.add(Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: widget.textPadding ?? EdgeInsets.zero,
          child: Text(
            item.text,
            style: TextStyle(
                color: (item.textColor ?? widget.textColor) ?? Color(0xff222222),
                fontSize: (item.textSize ?? widget.textSize) ?? 14,
                fontWeight: ((item.textBold ?? widget.textBold) ?? false) ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ));
    }
    lst.add(Expanded(
        child: Align(
      alignment: item.secondaryAlignment ?? Alignment.centerLeft,
      child: Padding(
        padding: widget.secondaryPadding ?? EdgeInsets.zero,
        child: Text(
          item.secondary ?? "",
          style: TextStyle(
              color: (item.secondaryColor ?? widget.secondaryColor) ?? Color(0xffA7A7A7),
              fontSize: (item.secondarySize ?? widget.secondarySize) ?? 12,
              fontWeight:
                  ((item.secondaryBold ?? widget.secondaryBold) ?? false) ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    )));
    if (item.mark.isNotEmptyString) {
      lst.add(Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: widget.markPadding ?? EdgeInsets.zero,
          child: Text(
            item.mark,
            style: TextStyle(
                color: (item.markColor ?? widget.markColor) ?? Color(0xffA7A7A7),
                fontSize: (item.markSize ?? widget.markSize) ?? 12,
                fontWeight: ((item.markBold ?? widget.markBold) ?? false) ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ));
    }
    if (item.markWidget != null) {
      lst.add(Container(
        margin: widget.markIconMargin ?? EdgeInsets.zero,
        child: item.markWidget,
      ));
    }
    if (item.markIcon != null) {
      lst.add(Container(
        margin: widget.markIconMargin ?? EdgeInsets.zero,
        child: item.markIcon,
      ));
    }
    return lst;
  }
}
