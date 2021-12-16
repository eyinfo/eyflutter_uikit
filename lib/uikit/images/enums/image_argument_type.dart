/// oss图片参数类型
enum ImageArgumentType {
  /// 图片信息
  exif,

  /// 自定义参数拼接
  custom,

  /// 根据宽度等比缩放
  resizeW,

  /// 根据高度等比缩放
  resizeH,

  /// 圆
  circle,

  /// 圆角
  corners
}
