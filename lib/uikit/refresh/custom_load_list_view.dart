import 'package:eyflutter_core/kit/utils/set/list_extention.dart';
import 'package:flutter/material.dart';

class CustomLoadListView extends StatefulWidget {
  /// 空视图
  final Widget? emptyView;

  /// 列表数据
  final List? list;

  /// 条目构建
  final IndexedWidgetBuilder? itemBuilder;

  /// 条目分隔线
  final IndexedWidgetBuilder? separatorBuilder;

  const CustomLoadListView({Key? key, this.emptyView, this.list, this.itemBuilder, this.separatorBuilder})
      : super(key: key);

  @override
  _CustomLoadListViewState createState() => _CustomLoadListViewState();
}

class _CustomLoadListViewState extends State<CustomLoadListView> {
  ScrollController _scrollController = ScrollController();
  String loadText = "加载中...";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [buildEmptyView()],
    );
  }

  Widget buildListView() {
    return Offstage(
      offstage: widget.list.isEmptyList,
      child: ListView.separated(
          controller: _scrollController,
          itemBuilder: widget.itemBuilder!,
          separatorBuilder: widget.separatorBuilder!,
          itemCount: (widget.list?.length ?? 0 + 1)),
    );
  }

  Widget buildEmptyView() {
    return Offstage(
      offstage: widget.emptyView == null,
      child: widget.emptyView ?? Container(),
    );
  }
}
