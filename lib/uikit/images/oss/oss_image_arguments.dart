import 'package:eyflutter_uikit/uikit/images/enums/image_format.dart';

class OssImageArguments {
  StringBuffer _buffer = StringBuffer();

  /// interlace,1设置图片为渐进显示
  /// auto-orient,1 对图片进行自适应旋转
  String get _prefix => "x-oss-process=image/interlace,1/auto-orient,1/sharpen,100/quality,q_80";

  OssImageArguments builder() {
    _buffer.write(_prefix);
    return this;
  }

  /// 图片格式转换
  OssImageArguments format(ImageFormat format) {
    _buffer..write("/format,${format.name}");
    return this;
  }

  /// 图片按宽等比缩放
  OssImageArguments resizeW(double width) {
    _buffer..write("/resize,w_${width.toInt()},m_lfit,limit_0");
    return this;
  }

  /// 图片按高度等比缩放
  OssImageArguments resizeH(double height) {
    _buffer..write("/resize,h_${height.toInt()},m_lfit,limit_0");
    return this;
  }

  /// 圆角
  OssImageArguments corners(double radius) {
    _buffer..write("/rounded-corners,r_${radius.toInt()}");
    return this;
  }

  /// 内切圆
  OssImageArguments circle(double radius) {
    _buffer..write("/circle,r_${radius.toInt()}");
    return this;
  }

  /// 设置模糊效果
  /// [r] 设置模糊半径,[1,50]该值越大，图片越模糊。
  /// [s] 设置正态分布的标准差,[1,50]该值越大，图片越模糊。
  OssImageArguments blur(int r, int s) {
    _buffer..write("blur,r_$r,s_$s");
    return this;
  }

  StringBuffer toBuffer() {
    return _buffer;
  }
}
