import 'package:eyflutter_core/kit/utils/set/list_extention.dart';
import 'package:eyflutter_uikit/uikit/bars/opacity_app_bar.dart';
import 'package:eyflutter_uikit/uikit/tabs/tab_widget.dart';
import 'package:flutter/material.dart';

mixin OnTabChange {
  void tabChangeItem(int index);
}

typedef TabBuildCallback = void Function(OnTabChange tabChange);
typedef TabChangeListener = void Function(int index, dynamic extra);

class TabPages extends StatefulWidget {
  /// 选项
  final List<TabWidget>? tabs;

  /// 选项内容页面
  final List<Widget>? pages;

  /// 选项卡高度(默认40)
  final double tabHeight;

  /// 选项卡背景
  final Color tabBackgroundColor;

  /// 选择文本颜色
  final Color? selectedLabelColor;

  /// 未选择文本颜色
  final Color? unselectedLabelColor;

  /// 指示器颜色
  final Color? indicatorColor;

  /// 指示器左右边距(可以控制指示器宽度)
  final double indicatorPadding;

  /// 初始化选项卡索引
  final int initialIndex;

  /// tab组件构建完成回调
  final TabBuildCallback? buildCallback;

  /// 选项改变监听
  final TabChangeListener? change;

  /// tab是否允许滚动(默认true)
  final bool isScrollable;

  /// 文本样式
  final TextStyle? labelStyle;

  /// tabPage样式
  final TabPageStyle style;

  /// tab bar下面分割线高度
  final double elevation;

  /// tab bar下面分割线颜色(isHiddenAppBar==false时值无效)
  final Color elevationColor;

  /// 指style==TabPageStyle.suckTop时tab至顶部之间的视图高度
  final double topViewHeight;

  /// 顶部视图组件
  final Widget? topWidget;

  /// app bar title
  final String title;

  /// app bar 右边按钮
  final List<Widget>? actions;

  const TabPages({
    Key? key,
    this.tabs,
    this.pages,
    this.tabHeight = 40,
    this.tabBackgroundColor = Colors.transparent,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.indicatorPadding = 2,
    this.initialIndex = 0,
    this.buildCallback,
    this.change,
    this.isScrollable = true,
    this.labelStyle,
    this.style = TabPageStyle.normal,
    this.elevation = 0.8,
    this.elevationColor = const Color(0xFFEEEEEE),
    this.topViewHeight = 0,
    this.topWidget,
    this.title = "",
    this.actions,
  }) : super(key: key);

  @override
  _TabPagesState createState() => _TabPagesState();
}

class _TabPagesState extends State<TabPages> with SingleTickerProviderStateMixin, OnTabChange {
  TabController? _tabController;
  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  int _initIndex = 0;

  //用于控件透明导航条操作
  OpacityAppBarOption? appBarOption;

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex < 0) {
      _initIndex = 0;
    } else if (widget.initialIndex >= (widget.tabs?.length ?? 0)) {
      _initIndex = widget.tabs?.length ?? 1 - 1;
    } else {
      _initIndex = widget.initialIndex;
    }
    _tabController = TabController(length: widget.tabs?.length ?? 0, vsync: this, initialIndex: _initIndex);
    _tabController!.addListener(() {
      if (_currentIndex == _tabController!.index) {
        return;
      }
      _currentIndex = _tabController!.index;
      var tab = widget.tabs?[_currentIndex];
      if (widget.change != null) {
        widget.change!(_currentIndex, tab?.extra);
      }
    });
    if (widget.buildCallback != null) {
      widget.buildCallback!(this);
    } else {
      if (widget.tabs.isNotEmptyList) {
        var tab = widget.tabs?[_initIndex];
        if (widget.change != null) {
          widget.change!(_initIndex, tab?.extra);
        }
      }
    }
    //suckTop时NestedScrollView滑动监听
    _scrollController.addListener(_nestedScrollListener);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.style == TabPageStyle.hiddenAppBar) {
      return _buildHiddenAppBarTabPageWidget();
    } else if (widget.style == TabPageStyle.suckTop) {
      return _buildSuckTopTabPageWidget();
    } else {
      return _buildNormalTabPageWidget();
    }
  }

  Widget _buildSuckTopTabPageWidget() {
    return DefaultTabController(
      length: widget.tabs?.length ?? 0,
      child: Scaffold(
        body: Container(
          child: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, bool) {
                  return [
                    _buildSuckWidget(),
                    SliverPersistentHeader(
                      delegate: _SliverTabBarDelegate(_buildTabBar(),
                          height: widget.tabHeight, color: widget.tabBackgroundColor),
                      pinned: true,
                    )
                  ];
                },
                body: TabBarView(controller: _tabController, children: widget.pages ?? []),
                controller: _scrollController,
              ),
              OpacityAppBar(
                call: _opacityAppBarCall,
                title: widget.title,
                actions: widget.actions,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _opacityAppBarCall(OpacityAppBarOption option) {
    this.appBarOption = option;
  }

  void _nestedScrollListener() {
    double total = widget.topViewHeight - (appBarOption?.getAppBarHeight() ?? 0);
    if (_scrollController.offset >= total) {
      appBarOption?.updateOpacity(1.0);
    } else if (_scrollController.offset <= 0) {
      appBarOption?.updateOpacity(0.0);
    } else {
      double opacity = _scrollController.offset / total;
      appBarOption?.updateOpacity(opacity);
    }
  }

  Widget _buildSuckWidget() {
    return SliverAppBar(
      centerTitle: true,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      shadowColor: Colors.white,
      expandedHeight: widget.topViewHeight,
      flexibleSpace: SingleChildScrollView(
        child: widget.topWidget,
      ),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      isScrollable: widget.isScrollable,
      controller: _tabController,
      tabs: widget.tabs ?? [],
      labelColor: widget.selectedLabelColor,
      unselectedLabelColor: widget.unselectedLabelColor,
      indicatorColor: widget.indicatorColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: widget.labelStyle,
      indicatorPadding:
          EdgeInsets.only(top: 0, left: widget.indicatorPadding, right: widget.indicatorPadding, bottom: 0),
    );
  }

  Widget _buildHiddenAppBarTabPageWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: widget.tabHeight,
            color: widget.tabBackgroundColor,
            child: _buildTabBar(),
          ),
          Container(
            width: double.infinity,
            height: widget.elevation,
            color: widget.elevationColor,
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: widget.pages ?? []),
          )
        ],
      ),
    );
  }

  Widget _buildNormalTabPageWidget() {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: widget.tabHeight,
          elevation: widget.elevation,
          backgroundColor: Colors.white,
          actions: widget.actions ?? [],
          flexibleSpace: SafeArea(
            child: Container(
              color: widget.tabBackgroundColor,
              child: _buildTabBar(),
            ),
          ),
        ),
        body: TabBarView(controller: _tabController, children: widget.pages ?? []));
  }

  @override
  void tabChangeItem(int index) {
    if (index < 0) {
      index = 0;
    } else if (index >= (widget.tabs?.length ?? 1)) {
      index = widget.tabs?.length ?? 1 - 1;
    }
    _tabController?.index = index;
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar widget;
  final Color? color;
  final double? height;

  const _SliverTabBarDelegate(this.widget, {this.color, this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: widget,
      color: color,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }

  @override
  double get maxExtent => height ?? 0;

  @override
  double get minExtent => height ?? 0;
}
