import 'package:flutter/material.dart';

import 'flutter_custom_dialog.dart';

typedef OnDialogDismissCall = void Function();

///1.初始化dialog:YYDialog.init(context);
///2.show dialog:DialogPanel.show[xxx];
class DialogPanel {
  ///显示底部弹出panel view
  ///[gravity]dialog panel出现的位置(默认从底部弹出)
  static YYDialog showDialogPanel(BuildContext context,
      {gravity,
      container,
      borderRadius = 4.0,
      margin = const EdgeInsets.all(0),
      barrierDismissible = true,
      double dx = 0,
      double dy = 0,
      OnDialogDismissCall? dismissCall}) {
    return YYDialog().build(context)
      ..gravity = gravity ?? Gravity.bottom
      ..gravityAnimationEnable = true
      ..borderRadius = borderRadius ?? 4.0
      ..widget(container)
      ..margin = margin
      ..barrierColor = Colors.black.withOpacity(.3)
      ..barrierDismissible = barrierDismissible ?? true
      ..dismissCallBack = dismissCall!
      ..show();
  }

  ///消息框(出现在屏幕中间)
  static YYDialog showMessageDialog(BuildContext context,
      {gravity,
      container,
      borderRadius = 4.0,
      barrierDismissible = true,
      double dx = 0,
      double dy = 0,
      margin = const EdgeInsets.all(0),
      OnDialogDismissCall? dismissCall}) {
    return showDialogPanel(context,
        gravity: gravity ?? Gravity.center,
        container: container,
        borderRadius: borderRadius,
        margin: margin,
        dx: dx,
        dy: dy,
        barrierDismissible: barrierDismissible,
        dismissCall: dismissCall);
  }
}
