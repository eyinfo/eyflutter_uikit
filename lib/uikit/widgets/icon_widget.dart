import 'package:flutter/material.dart';

class IconWidget extends Icon {
  IconWidget(IconData icon,
      {Key? key,
      double? size,
      Color? color,
      String? semanticLabel,
      TextDirection? textDirection,
      this.isVisible = true,
      this.padding = const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
      this.width,
      this.height})
      : super(icon, key: key, size: size, color: color, semanticLabel: semanticLabel, textDirection: textDirection);

  //是否显示组件，默认显示
  final bool isVisible;

  //cs icon padding
  final EdgeInsetsGeometry padding;

  /// 控件宽度
  final double? width;

  /// 控件高度
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !isVisible,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: super.build(context),
      ),
    );
  }
}
