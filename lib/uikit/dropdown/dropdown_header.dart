import 'package:eyflutter_uikit/uikit/dropdown/dropdown_menu_controller.dart';
import 'package:flutter/material.dart';

/// Signature for when a tap has occurred.
typedef OnItemTap<T> = void Function(T value);

/// Dropdown header widget.
class DropDownHeader extends StatefulWidget {
  final Color color;
  final double borderWidth;
  final Color borderColor;
  final TextStyle style;
  final TextStyle dropDownStyle;
  final EdgeInsets padding;

//  final List<String> menuStrings;
  final double height;
  final double dividerHeight;
  final Color dividerColor;
  final DropdownMenuController controller;
  final OnItemTap? onItemTap;
  final List<DropDownHeaderItem> items;
  final GlobalKey stackKey;

  /// Creates a dropdown header widget, Contains more than one header items.
  DropDownHeader({
    Key? key,
    required this.items,
    required this.controller,
    required this.stackKey,
    this.style = const TextStyle(color: Color(0xFF666666), fontSize: 13),
    this.dropDownStyle = const TextStyle(color: Color(0xFF333333), fontSize: 13),
    this.height = 40,
    this.borderWidth = 1,
    this.borderColor = const Color(0xFFeeede6),
    this.dividerHeight = 20,
    this.dividerColor = const Color(0xFFeeede6),
    this.padding = EdgeInsets.zero,
    this.onItemTap,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  _DropDownHeaderState createState() => _DropDownHeaderState();
}

class _DropDownHeaderState extends State<DropDownHeader> with SingleTickerProviderStateMixin {
  bool _isShowDropDownItemWidget = false;
  double? _screenWidth;
  int? _menuCount;
  GlobalKey _keyDropDownHeader = GlobalKey();
  TextStyle? _dropDownStyle;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  _onController() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _dropDownStyle = widget.dropDownStyle ?? TextStyle(color: Theme.of(context).primaryColor, fontSize: 13);
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _menuCount = widget.items.length;

    var gridView = GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: _menuCount ?? 0,
      childAspectRatio:
          (((_screenWidth ?? 0) - widget.padding.left - widget.padding.right) / (_menuCount ?? 0)) / widget.height,
      children: widget.items.map<Widget>((item) {
        return _menu(item);
      }).toList(),
    );

    return Container(
      key: _keyDropDownHeader,
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: gridView,
    );
  }

  dispose() {
    super.dispose();
  }

  _menu(DropDownHeaderItem item) {
    int index = widget.items.indexOf(item);
    int menuIndex = widget.controller.menuIndex;
    _isShowDropDownItemWidget = index == menuIndex && widget.controller.isShow;

    return GestureDetector(
      onTap: () {
        final RenderBox overlay = widget.stackKey.currentContext?.findRenderObject() as RenderBox;
        final RenderBox dropDownItemRenderBox = _keyDropDownHeader.currentContext?.findRenderObject() as RenderBox;
        var position = dropDownItemRenderBox.localToGlobal(Offset.zero, ancestor: overlay);
        var size = dropDownItemRenderBox.size;
        widget.controller.dropDownMenuTop = size.height + position.dy;
        if (index == menuIndex) {
          if (widget.controller.isShow) {
            widget.controller.hide();
          } else {
            widget.controller.show(index);
          }
        } else {
          if (widget.controller.isShow) {
            widget.controller.hide(isShowHideAnimation: false);
          }
          widget.controller.show(index);
        }
        if (widget.onItemTap != null) {
          widget.onItemTap!(index);
        }
        setState(() {});
      },
      child: Container(
        color: widget.color,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: item.mainAxisAlignment,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _isShowDropDownItemWidget ? _dropDownStyle : widget.style.merge(item.style),
                    ),
                  ),
                  item.widget,
                  Container(
                    padding: EdgeInsets.only(left: 2),
                    child: !_isShowDropDownItemWidget ? item.iconData : item.iconDropDownData,
                  ),
                ],
              ),
            ),
            index == widget.items.length - 1
                ? Container()
                : Container(
                    height: widget.dividerHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: widget.dividerColor, width: 1),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DropDownHeaderItem {
  final String title;
  final Widget widget;
  final Widget iconData;
  final Widget iconDropDownData;
  final MainAxisAlignment mainAxisAlignment;
  final TextStyle? style;

  DropDownHeaderItem(
    this.title, {
    this.widget = const SizedBox(width: 0, height: 0),
    this.iconData = const Icon(Icons.arrow_drop_down),
    this.iconDropDownData = const Icon(Icons.arrow_drop_up),
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.style,
  });
}
