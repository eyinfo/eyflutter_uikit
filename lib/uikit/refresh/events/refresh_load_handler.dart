mixin RefreshLoadHandler {
  /// 加载组件高度
  double loadHeight();

  /// 加载组件文本颜色
  int loadTextColor();

  /// 加载中文本
  String loadingText();

  /// 没有更多数据
  String noDataText();

  /// 未达到加载之前显示文本
  String loadIdleText();

  /// 松开加载数据
  String loadReleaseText();

  /// 加载完成
  String loadCompleteText();
}
