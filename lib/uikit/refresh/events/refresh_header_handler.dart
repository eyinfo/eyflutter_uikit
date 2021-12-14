mixin RefreshHeaderHandler {
  /// 未达到刷新条件时提示文本
  String idleText();

  /// 头部文本颜色
  int headerTextColor();

  /// 松开刷新数据
  String releaseText();

  /// 刷新视图高度
  double refreshHeight();

  /// 数据刷新中
  String refreshingText();

  /// 刷新失败
  String refreshFailedText();

  /// 刷新完成提示文本
  String completeText();
}
