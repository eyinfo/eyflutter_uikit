import 'package:flutter/material.dart';

typedef SearchBarClick = void Function();

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  /// 搜索条高度
  final double height;

  /// 导航栏背景颜色
  final Color? backgroundColor;

  /// 搜索条下方分割线高度
  final double underlineHeight;

  /// 搜索条下方分割线颜色
  final Color underlineColor;

  /// 是否显示搜索条下方分割线(默认隐藏)
  final bool visibilityUnderline;

  /// 搜索条边框宽度(默认1)
  final double borderWidth;

  /// 搜索条边框颜色
  final Color borderColor;

  /// 搜索条边框圆角(默认4)
  final double borderRadius;

  /// 搜索条背景色
  final Color color;

  /// 搜索条外边距
  final EdgeInsetsGeometry margin;

  /// 搜索文本字号(默认14)
  final double textFontSize;

  /// 搜索文本颜色
  final Color textColor;

  /// 搜索文本提示内容
  final String hint;

  /// 搜索图标
  final Icon searchIcon;

  /// 单击事件回调
  final SearchBarClick? click;

  const SearchBar(
      {Key? key,
      this.height = 46,
      this.backgroundColor,
      this.underlineHeight = 0,
      this.underlineColor = const Color(0xFFeeeeee),
      this.visibilityUnderline = false,
      this.borderWidth = 1,
      this.borderColor = const Color(0xffe5e5e5),
      this.color = const Color(0xffffffff),
      this.margin = const EdgeInsets.only(left: 20, top: 4, right: 20, bottom: 6),
      this.borderRadius = 4,
      this.textFontSize = 14.0,
      this.textColor = const Color(0xff1A1A1A),
      this.hint = "点击这里开始搜索吧",
      this.searchIcon = const Icon(
        Icons.search,
        color: Color(0xffA6A6A6),
      ),
      this.click})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: SafeArea(
        top: true,
        child: new Container(
            decoration: new UnderlineTabIndicator(
              borderSide: BorderSide(
                  width: widget.visibilityUnderline ? widget.underlineHeight : 0,
                  color: widget.visibilityUnderline ? widget.underlineColor : Color(0x00000000)),
            ),
            height: widget.height,
            child: GestureDetector(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: widget.borderColor, width: widget.borderWidth),
                    color: widget.color,
                    borderRadius: BorderRadius.circular(widget.borderRadius)),
                margin: widget.margin,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: widget.searchIcon,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, right: 10),
                        child: Text(
                          widget.hint,
                          style: TextStyle(
                            fontSize: widget.textFontSize,
                            color: widget.textColor,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                if (widget.click != null) {
                  widget.click!();
                }
              },
            )),
      ),
    );
  }
}
