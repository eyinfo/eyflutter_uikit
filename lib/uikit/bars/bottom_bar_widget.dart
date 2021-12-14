import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:eyflutter_core/kit/utils/double_extension.dart';
import 'package:eyflutter_core/kit/utils/set/list_extention.dart';
import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:flutter/material.dart';

mixin BottomBarController {
  /// 选择回调
  void onBottomBarItemSelected(int index);
}

mixin BottomBarListener {
  /// 选项单击回调
  /// [currentIndex] 选择项索引
  /// [tag] 选项标记
  /// [extra] 扩展数据(eg. 携带数据)
  Future<bool> onBottomBarItemClick(int currentIndex, String tag, dynamic extra);

  /// 组件构建完成后传入BottomBarController
  void onBottomBarBuilder(BottomBarController controller);
}

/// 底部导航样式
enum BottomBarStyle {
  /// 经典效果
  classic,

  /// 中间悬浮按钮效果
  middleFloating,

  /// 中间凸起效果
  middleConvex
}

class BottomBarItem {
  /// 正常显示图标
  Widget icon;

  /// 选中时图标
  Widget activeIcon;

  /// 选项图标文本
  String text;

  /// 选项标识
  String tag;

  /// 扩展数据
  dynamic extra;

  /// 是否特殊按钮(该属性内部使用)
  bool isConvex;

  /// 选项索引(排除特殊按钮之外)
  int tabIndex;

  ///默认图片自定义宽高
  SizedBox normalIconSize;

  ///选中图片自定义宽高
  SizedBox selectedIconSize;

  /// 默认是否隐藏text
  bool normalHiddenText;

  /// 选中是否隐藏text
  bool selectedHiddenText;

  BottomBarItem(
      {this.icon,
      this.activeIcon,
      this.text,
      this.tag,
      this.extra,
      this.normalIconSize,
      this.selectedIconSize,
      this.selectedHiddenText = false,
      this.normalHiddenText = false,
      this.isConvex = false,
      this.tabIndex = 0});
}

class BottomConvexAction {
  /// 中间组件
  final Widget widget;

  /// 文本，可为空
  final String text;

  /// 按钮标识
  final String tag;

  /// 扩展数据
  final dynamic extra;

  /// 按钮大小
  /// 只在barStyle=BottomBarStyle.middleConvex时有效
  final double size;

  /// 按钮背景颜色
  final Color backgroundColor;

  BottomConvexAction({this.widget, this.text, this.tag, this.extra, this.size, this.backgroundColor});
}

class BottomBarWidget extends StatefulWidget {
  /// 导航条样式
  final BottomBarStyle barStyle;

  /// 默认文本颜色
  final Color color;

  /// 选中文本颜色
  final Color fixedColor;

  /// tab选项集合
  final List<BottomBarItem> items;

  /// BottomBar监听器
  final BottomBarListener listener;

  /// tab页面组件
  final List<Widget> tabWidgets;

  /// 背景颜色
  final Color backgroundColor;

  /// 内嵌按钮(仅当(barStyle=BottomBarStyle.middleFloating||barStyle=BottomBarStyle.middleConvex)且items.length%2 == 0时有效)
  final BottomConvexAction convexAction;

  /// 导航条高度
  final double height;

  /// barStyle=BottomBarStyle.middleConvex
  /// top edge of the convex shape relative to AppBar
  /// https://github.com/hacktons/convex_bottom_bar
  final double top;

  /// 当前选中项
  final int currentItem;

  /// 图标大小
  final double iconSize;

  /// 悬浮或凸出图标外边距(默认8)
  final double convexIconMargin;

  /// 导航文字大小
  final double fontSize;

  /// 文本图片之间间距
  final double drawablePadding;

  const BottomBarWidget(
      {Key key,
      this.barStyle,
      this.color,
      this.fixedColor,
      this.items,
      this.listener,
      this.tabWidgets,
      this.backgroundColor,
      this.convexAction,
      this.height = 60,
      this.top = 0,
      this.currentItem = 0,
      this.iconSize = 20,
      this.convexIconMargin = 5,
      this.fontSize = 12,
      this.drawablePadding = 5})
      : super(key: key);

  @override
  _BottomBarWidgetState createState() => _BottomBarWidgetState();
}

class _Style extends StyleHook {
  final double navIconSize;
  final double convexIconMargin;
  final double fontSize;

  _Style({this.navIconSize, this.convexIconMargin, this.fontSize});

  @override
  double get activeIconSize => navIconSize;

  @override
  double get activeIconMargin => this.convexIconMargin;

  @override
  double get iconSize => this.navIconSize;

  @override
  TextStyle textStyle(Color color) {
    return TextStyle(fontSize: this.fontSize, color: color);
  }
}

class _BottomBarWidgetState extends State<BottomBarWidget> with BottomBarController {
  int _currentIndex = 0;
  List<BottomBarItem> actualItems = [];
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    widget.listener?.onBottomBarBuilder(this);
    _currentIndex = widget.currentItem;
    _pageController = PageController(initialPage: this._currentIndex, keepPage: true);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void onBottomBarItemSelected(int index) {
    setCurrentItem(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.barStyle == BottomBarStyle.middleFloating) {
      return Scaffold(
        body: _buildPageView(),
        floatingActionButton: _buildFloatButton(),
        floatingActionButtonLocation: (widget.convexAction == null || actualItems.length % 2 != 0)
            ? null
            : FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildMiddleFloatView(),
      );
    } else if (widget.barStyle == BottomBarStyle.middleConvex) {
      return Scaffold(
        body: _buildIndexedStackView(),
        bottomNavigationBar: _buildConvexNavBar(context),
      );
    } else {
      return Scaffold(
        body: _buildIndexedStackView(),
        bottomNavigationBar: _buildClassicBar(_toBottomNavigationBar()),
      );
    }
  }

  PageView _buildPageView() {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: widget.tabWidgets,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  IndexedStack _buildIndexedStackView() {
    return IndexedStack(
      index: _currentIndex,
      children: widget.tabWidgets,
    );
  }

  Widget _buildConvexNavBar(BuildContext context) {
    return StyleProvider(
        style:
            _Style(navIconSize: widget.iconSize, convexIconMargin: widget.convexIconMargin, fontSize: widget.fontSize),
        child: ConvexAppBar(
          items: _toMiddleConvexWidgets(),
          initialActiveIndex: _currentIndex,
          height: widget.height,
          top: widget.top > 0 ? 0 : widget.top,
          curveSize: widget.convexAction.size + 12,
          backgroundColor: widget.backgroundColor,
          color: widget.color,
          activeColor: widget.fixedColor,
          elevation: 0,
          onTap: (int index) async {
            _convexItemClick(index);
          },
          onTabNotify: (index) {
            var intercept = (index == (actualItems.length / 2).doubleInt);
            if (intercept) {
              BottomBarItem barItem = actualItems[index];
              widget.listener?.onBottomBarItemClick(-1, barItem.tag, barItem.extra);
            }
            return !intercept;
          },
          style: TabStyle.fixedCircle,
        ));
  }

  void _convexItemClick(int index) async {
    BottomBarItem barItem = actualItems[index];
    if (!barItem.isConvex) {
      var isIntercept =
          await widget.listener?.onBottomBarItemClick(barItem.tabIndex, barItem.tag, barItem.extra) ?? false;
      if (!isIntercept) {
        setState(() {
          _currentIndex = barItem.tabIndex;
        });
      }
    }
  }

  /// 设置并切换当前项
  /// [position]
  void setCurrentItem(int position) {
    if (position < 0) {
      position = 0;
    }
    if (position >= actualItems.length) {
      position = actualItems.length - 1;
    }
    if (widget.barStyle == BottomBarStyle.middleFloating) {
      _middleFloatItemClick(position);
    } else if (widget.barStyle == BottomBarStyle.middleConvex) {
      _convexItemClick(position);
    } else {
      _classicItemClick(position);
    }
  }

  List<TabItem> _toMiddleConvexWidgets() {
    if (widget.items.isEmptyList) {
      return [];
    }
    actualItems.clear();
    List<TabItem> lst = [];
    int index = 0;
    int mIndex = (widget.items.length / 2).doubleInt;
    widget.items?.forEach((element) {
      if (element.icon != null && element.activeIcon != null && element.text.isNotEmptyString) {
        actualItems.add(BottomBarItem(
            icon: element.icon,
            activeIcon: element.activeIcon,
            text: element.text,
            tag: element.tag,
            extra: element.extra,
            tabIndex: index));
        var item = TabItem<Image>(icon: element.icon, activeIcon: element.activeIcon, title: element.text);
        lst.add(item);
        if (widget.convexAction != null && widget.items.length % 2 == 0 && (index + 1) == mIndex) {
          actualItems.add(BottomBarItem(
              icon: widget.convexAction.widget,
              activeIcon: widget.convexAction.widget,
              text: widget.convexAction.text,
              tag: widget.convexAction.tag,
              extra: widget.convexAction.extra,
              isConvex: true));
          lst.add(TabItem<Widget>(
              icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.convexAction.backgroundColor,
            ),
            child: widget.convexAction.widget,
          )));
        }
        index++;
      }
    });
    return lst;
  }

  Widget _buildFloatButton() {
    if (widget.convexAction == null || actualItems.length % 2 != 0) {
      return null;
    }
    return _BottomFloatingActionButton(
      convexAction: widget.convexAction,
      listener: widget.listener,
    );
  }

  BottomAppBar _buildMiddleFloatView() {
    return BottomAppBar(
      color: widget.backgroundColor,
      shape: CircularNotchedRectangle(),
      child: Container(
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _toMiddleFloatingWidgets(),
        ),
      ),
    );
  }

  List<Widget> _toMiddleFloatingWidgets() {
    if (widget.items.isEmptyList) {
      return [];
    }
    actualItems.clear();
    List<Widget> lst = [];
    int index = 0;
    int mIndex = (widget.items.length / 2).doubleInt;
    widget.items?.forEach((element) {
      element.tabIndex = index;
      if (element.icon != null && element.activeIcon != null && element.text.isNotEmptyString) {
        actualItems.add(element);
        lst.add(_buildBarItemGestureDetector(index, element));
        if (widget.convexAction != null && widget.items.length % 2 == 0 && (index + 1) == mIndex) {
          lst.add(Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.convexAction.widget,
              Text(widget.convexAction.text ?? "", style: TextStyle(color: widget.color, fontSize: widget.fontSize))
            ],
          ));
        }
        index++;
      }
    });
    return lst;
  }

  Widget _buildBarItemGestureDetector(int index, BottomBarItem barItem) {
    return FlatButton(
      padding: EdgeInsets.only(left: 4, top: 2, right: 4, bottom: 2),
      shape: new CircleBorder(
          side: new BorderSide(
        style: BorderStyle.none,
      )),
      child: _buildMiddleConvexItem(index, barItem),
      onPressed: () async {
        _middleFloatItemClick(index);
      },
      textColor: widget.color,
    );
  }

  void _middleFloatItemClick(int index) async {
    BottomBarItem barItem = actualItems[index];
    if (!barItem.isConvex) {
      var isIntercept =
          await widget.listener?.onBottomBarItemClick(barItem.tabIndex, barItem.tag, barItem.extra) ?? false;
      if (!isIntercept) {
        setState(() {
          _currentIndex = barItem.tabIndex;
          _pageController.jumpToPage(index);
        });
      }
    } else {
      setState(() {
        _currentIndex = barItem.tabIndex;
        _pageController.jumpToPage(index);
      });
    }
  }

  Widget _buildMiddleConvexItem(int index, BottomBarItem barItem) {
    List<Widget> childList = [];

    if (_currentIndex != index) {
      childList.add(_buildMiddleItemIcon(false, barItem));
      if (!barItem.normalHiddenText) {
        childList.add(_buildMiddleItemText(false, barItem));
      }
    } else {
      childList.add(_buildMiddleItemIcon(true, barItem));
      if (!barItem.selectedHiddenText) {
        childList.add(_buildMiddleItemText(true, barItem));
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: childList);
  }

  Widget _buildMiddleItemText(bool isselected, BottomBarItem barItem) {
    return Text(
      barItem.text,
      style: TextStyle(color: isselected ? widget.fixedColor : widget.color, fontWeight: FontWeight.normal),
    );
  }

  Widget _buildMiddleItemIcon(bool isselected, BottomBarItem barItem) {
    double width = widget.iconSize;
    double height = widget.iconSize;
    double topPadding = 4;
    if (isselected) {
      if (barItem.selectedIconSize != null) {
        width = barItem.selectedIconSize.width;
        height = barItem.selectedIconSize.height;
        topPadding = 0;
      }
    } else {
      if (barItem.normalIconSize != null) {
        width = barItem.normalIconSize.width;
        height = barItem.normalIconSize.height;
        topPadding = 0;
      }
    }
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        width: width,
        height: height,
        child: isselected ? barItem.activeIcon : barItem.icon,
      ),
    );
  }

  List<BottomNavigationBarItem> _toBottomNavigationBar() {
    if (widget.items.isEmptyList) {
      return [];
    }
    actualItems.clear();
    List<BottomNavigationBarItem> lst = [];
    int index = 0;
    widget.items?.forEach((element) {
      if (element.icon != null && element.activeIcon != null && element.text.isNotEmptyString) {
        element.tabIndex = index;
        actualItems.add(element);
        lst.add(BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: widget.drawablePadding),
              child: SizedBox(
                width: widget.iconSize,
                height: widget.iconSize,
                child: element.icon,
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: widget.drawablePadding),
              child: SizedBox(
                width: widget.iconSize,
                height: widget.iconSize,
                child: element.activeIcon,
              ),
            ),
            label: element.text));
        index++;
      }
    });
    return lst;
  }

  BottomNavigationBar _buildClassicBar(List<BottomNavigationBarItem> items) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      unselectedItemColor: widget.color,
      fixedColor: widget.fixedColor,
      backgroundColor: widget.backgroundColor,
      items: items,
      iconSize: widget.iconSize,
      onTap: (int index) async {
        _classicItemClick(index);
      },
    );
  }

  void _classicItemClick(int index) async {
    BottomBarItem barItem = actualItems[index];
    if (!barItem.isConvex) {
      var isIntercept =
          await widget.listener?.onBottomBarItemClick(barItem.tabIndex, barItem.tag, barItem.extra) ?? false;
      if (!isIntercept) {
        setState(() {
          _currentIndex = barItem.tabIndex;
        });
      }
    }
  }
}

class _BottomFloatingActionButton extends StatelessWidget {
  final BottomConvexAction convexAction;
  final BottomBarListener listener;

  const _BottomFloatingActionButton({Key key, this.convexAction, this.listener}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.only(top: 5),
      height: convexAction.size,
      width: convexAction.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),
        color: Colors.white,
      ),
      child: FloatingActionButton(
        elevation: 0,
        backgroundColor: convexAction.backgroundColor,
        child: convexAction.widget,
        onPressed: () {
          listener?.onBottomBarItemClick(-1, convexAction.tag, convexAction.extra);
        },
      ),
    );
  }
}
