import 'package:eyflutter_uikit/utils/media_utils.dart';
import 'package:flutter/material.dart';

typedef OnTextButtonCall = void Function();

class TextCornersButton extends StatefulWidget {
  /// 文本
  final String text;

  /// 文本颜色
  final Color textColor;

  /// 文本字体大小
  final double fontSize;

  /// 文本是否加粗
  final bool isBold;

  /// 按钮宽度
  final double width;

  /// 按钮高度
  final double height;

  /// 按钮外边距
  final EdgeInsetsGeometry margin;

  /// 按钮单击事件
  final OnTextButtonCall buttonCall;

  /// 渐变颜色(从左到右)
  final List<Color> gradientColors;

  /// 按钮圆角
  final double radius;

  const TextCornersButton(
      {Key key,
      this.text,
      this.textColor = Colors.white,
      this.fontSize,
      this.isBold = true,
      this.width = double.infinity,
      this.height,
      this.margin = const EdgeInsets.only(left: 17, right: 17),
      this.buttonCall,
      this.gradientColors = const [Color(0xffFF4949), Color(0xffFF8123)],
      this.radius = 100})
      : super(key: key);

  @override
  _TextCornersButtonState createState() => _TextCornersButtonState();
}

class _TextCornersButtonState extends State<TextCornersButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? MediaUtils.instance.height(45),
      margin: widget.margin,
      child: TextButton(
        child: Text(
          widget.text,
          style: TextStyle(
              color: widget.textColor,
              fontSize: widget.fontSize ?? MediaUtils.instance.sp(13),
              fontWeight: widget.isBold ? FontWeight.bold : FontWeight.normal),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.radius))),
          overlayColor: MaterialStateProperty.all(Color(0xffFc8249).withOpacity(0.8)),
        ),
        onPressed: widget.buttonCall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: widget.gradientColors),
        borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
      ),
    );
  }
}
