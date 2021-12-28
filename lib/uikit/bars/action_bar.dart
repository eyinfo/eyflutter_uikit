import 'dart:collection';

import 'package:eyflutter_uikit/uikit/widgets/icon_widget.dart';
import 'package:flutter/material.dart';

/// this.leading,//在标题前面显示的一个控件，在首页通常显示应用的 logo；在其他界面通常显示为返回按钮
/// this.automaticallyImplyLeading = true,
/// this.title,//Toolbar 中主要内容，通常显示为当前界面的标题文字
/// this.actions,//一个 Widget 列表，代表 Toolbar 中所显示的菜单，对于常用的菜单，通常使用 IconButton 来表示；对于不常用的菜单通常使用 PopupMenuButton 来显示为三个点，点击后弹出二级菜单
/// this.flexibleSpace,//一个显示在 AppBar 下方的控件，高度和 AppBar 高度一样，可以实现一些特殊的效果，该属性通常在 SliverAppBar 中使用
/// this.bottom,//一个 AppBarBottomWidget 对象，通常是 TabBar。用来在 Toolbar 标题下面显示一个 Tab 导航栏
/// this.elevation = 4.0,//纸墨设计中控件的 z 坐标顺序，默认值为 4，对于可滚动的 SliverAppBar，当 SliverAppBar 和内容同级的时候，该值为 0， 当内容滚动 SliverAppBar 变为 Toolbar 的时候，修改 elevation 的值
/// this.backgroundColor,//APP bar 的颜色，默认值为 ThemeData.primaryColor。改值通常和下面的三个属性一起使用
/// this.brightness,//App bar 的亮度，有白色和黑色两种主题，默认值为 ThemeData.primaryColorBrightness
/// this.iconTheme,//App bar 上图标的颜色、透明度、和尺寸信息。默认值为 ThemeData.primaryIconTheme
/// this.textTheme,//App bar 上的文字样式。默认值为 ThemeData.primaryTextTheme
/// this.primary = true,
/// this.centerTitle,//标题是否居中显示，默认值根据不同的操作系统，显示方式不一样,true居中 false居左
/// this.titleSpacing = NavigationToolbar.kMiddleSpacing,
/// this.toolbarOpacity = 1.0,
/// this.bottomOpacity = 1.0,

/// 按钮事件
/// [key]widget key
/// [value]自定义值
typedef ActionClickHandle = void Function(String key, dynamic extra);

///ActionBar布局结构
enum ActionBarLayoutStruct {
  //仅左边控件
  leading,
  //仅右边控件
  actions,
  //仅中间主题显示控件
  theme,
  //仅左边和中间主题显示控件
  leadingTheme,
  //仅右边和中间主题显示控件
  actionsTheme,
  //左边控件、右边控件和中间主题显示控件
  leadingActionsTheme
}

class ActionBarStructItem {
  ActionBarStructItem({this.struct, this.leadingKeys, this.actionsKeys, this.themeKey, this.pageTag});

  ActionBarLayoutStruct? struct;

  //左边控件对应的Key值
  List<String>? leadingKeys;

  //右边控件对应的Key值
  List<String>? actionsKeys;

  //中间主题控件对应的Key值
  String? themeKey;

  //页面标识
  String? pageTag;
}

class ActionBar extends StatefulWidget implements PreferredSizeWidget {
  /// appbar高度
  final double height;

  /// 是否显示action bar,默认显示
  final bool isVisibleActionBar;

  /// 两边自定义视图预留的最大宽度(默认自适应)
  final double? edgesWidgetWidth;

  /// 背景颜色
  final Color backgroundColor;

  /// 是否显示分隔线
  final bool isShowDivider;

  /// 标题前面显示的按钮控件
  final List<Widget>? leadingActions;

  /// 操作项
  final List<Widget>? actions;

  /// 内容部件
  final Widget? content;

  /// 扩展数据
  final dynamic extra;

  /// action button点击(left button or right button)
  final ActionClickHandle? actionClick;

  /// content float
  final bool isFloatContent;

  const ActionBar(
      {Key? key,
      this.height = 46,
      this.isVisibleActionBar = true,
      this.edgesWidgetWidth,
      this.backgroundColor = const Color(0xFFFF4E00),
      this.isShowDivider = false,
      this.leadingActions,
      this.actions,
      this.content,
      this.actionClick,
      this.extra,
      this.isFloatContent = false})
      : super(key: key);

  @override
  _ActionBarState createState() => _ActionBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _ActionBarState extends State<ActionBar> {
  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !widget.isVisibleActionBar,
      child: AppBar(
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,
        title: Container(
          height: widget.height,
          child: _buildContent(),
        ),
        centerTitle: true,
        backgroundColor: widget.backgroundColor,
        elevation: widget.isShowDivider ? 1 : 0,
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isFloatContent) {
      return Stack(
        children: _prepareStackWidget(),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: _prepareWidget(),
      );
    }
  }

  List<Widget> _prepareStackWidget() {
    LinkedHashSet<Widget> map = new LinkedHashSet();
    if (widget.edgesWidgetWidth != null && (widget.edgesWidgetWidth ?? 0) > 0) {
      map.add(_groupWidget(_modifiedWidgets(widget.leadingActions ?? []), Alignment.centerLeft));
    } else {
      map.add(Expanded(
        child: Center(
          child: widget.content,
        ),
      ));
      map.add(Positioned(
        left: 0,
        child: Row(
          children: _modifiedWidgets(widget.leadingActions ?? []),
        ),
      ));
      map.add(Positioned(
        right: 0,
        child: Row(
          children: _modifiedWidgets(widget.actions ?? []),
        ),
      ));
    }
    return map.toList();
  }

  List<Widget> _prepareWidget() {
    LinkedHashSet<Widget> map = new LinkedHashSet();
    if (widget.edgesWidgetWidth != null && (widget.edgesWidgetWidth ?? 0) > 0) {
      map.add(_groupWidget(_modifiedWidgets(widget.leadingActions ?? []), Alignment.centerLeft));
    } else {
      map.addAll(_modifiedWidgets(widget.leadingActions ?? []));
    }
    map.add(Expanded(
      child: Center(
        child: widget.content,
      ),
    ));
    if (widget.edgesWidgetWidth != null && (widget.edgesWidgetWidth ?? 0) > 0) {
      map.add(_groupWidget(_modifiedWidgets(widget.actions ?? []), Alignment.centerRight));
    } else {
      map.addAll(_modifiedWidgets(widget.actions ?? []));
    }
    return map.toList();
  }

  List<Widget> _modifiedWidgets(List<Widget> widgets) {
    LinkedHashSet<Widget> map = new LinkedHashSet();
    widgets.forEach((Widget wg) {
      var action = getActionKey(wg);
      _buildItem(map, wg, action);
    });
    return map.toList();
  }

  void _buildItem(LinkedHashSet<Widget> map, Widget wg, String action) {
    if (wg is IconWidget) {
      bool _isVisible = wg.isVisible;
      map.add(
        Offstage(offstage: !_isVisible, child: _buildTextBtn(wg, action)),
      );
    } else {
      map.add(
        _buildTextBtn(wg, action),
      );
    }
  }

  Widget _buildTextBtn(Widget wg, String action) {
    return TextButton(
      child: wg,
      onPressed: () {
        if (widget.actionClick != null) {
          widget.actionClick!(action, widget.extra);
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(widget.backgroundColor),
        minimumSize: MaterialStateProperty.all(Size(
          0,
          widget.height,
        )),
        padding: MaterialStateProperty.all(EdgeInsets.all(0)),
      ),
    );
  }

  String getActionKey(Widget wg) {
    String actionKey = wg.key.toString();
    var regExp = new RegExp("[^\\[\\<'\\>\\]]", caseSensitive: false);
    StringBuffer mKey = StringBuffer();
    var matchList = regExp.allMatches(actionKey).toList();
    matchList.forEach((element) {
      mKey.write(element[0]);
    });
    if (mKey.length == 0) {
      return "";
    }
    return mKey.toString();
  }

  Widget _groupWidget(List<Widget> widgets, AlignmentGeometry alignment) {
    return Container(
      width: widget.edgesWidgetWidth,
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      ),
    );
  }
}
