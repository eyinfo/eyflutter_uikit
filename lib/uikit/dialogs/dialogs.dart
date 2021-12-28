import 'package:eyflutter_core/kit/utils/set/list_extention.dart';
import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:eyflutter_uikit/uikit/dialogs/dialog_panel.dart';
import 'package:eyflutter_uikit/uikit/dialogs/floating_panel.dart';
import 'package:eyflutter_uikit/uikit/dialogs/flutter_custom_dialog.dart';
import 'package:flutter/material.dart';

class ButtonArgs {
  /// 按钮文本
  final String text;

  /// 按钮文本颜色
  final Color? color;

  /// 是否加粗
  final bool isBold;

  /// 唯一标识符
  final String action;

  @deprecated
  final bool? isHighlighted;

  ButtonArgs({this.text = '', this.color, this.isBold = false, this.action = '', this.isHighlighted});
}

class DialogEntry {
  YYDialog? dialog;
}

class ListItem {
  /// list item text
  final String? text;

  /// 扩展数据
  final dynamic extra;

  ListItem({this.text, this.extra});
}

typedef OnButtonPressed(ButtonArgs buttonArgs);
typedef OnListItemPressed(ListItem item);
typedef OnDialogBuildCall(YYDialog dialog);

class Dialogs {
  factory Dialogs() => _getInstance();

  static Dialogs get instance => _getInstance();
  static Dialogs? _instance;

  static Dialogs _getInstance() {
    return _instance ??= new Dialogs._internal();
  }

  Dialogs._internal();

  /// 显示dialog(message优先级大于contentView)
  /// [context] widget context
  /// [backgroundColor] dialog背景颜色
  /// [borderRadius] 边框圆角大小
  /// [title] 标题
  /// [textAlign] 标题
  /// [message] 消息内容与contentView互斥,若设置message后contentView无效
  /// [contentView] 内容自定义视图与message互斥
  /// [buttonArgs] 按钮列表
  /// [buttonPressed] 按钮事件回调
  /// [isClickOutsideDismiss] 点击dialog外部是否消失
  /// [margin] dialog外边距
  /// [buildCall] 构建完成回调
  YYDialog showDialog(BuildContext context,
      {Color backgroundColor = Colors.white,
      double borderRadius = 6,
      String title = '',
      String message = '',
      Widget? contentView,
      List<ButtonArgs> buttonArgs = const <ButtonArgs>[],
      OnButtonPressed? buttonPressed,
      bool isClickOutsideDismiss = false,
      OnDialogBuildCall? buildCall,
      EdgeInsetsGeometry? padding,
      Gravity? gravity,
      bool isShowClose = false,
      TextAlign? textAlign,
      margin = const EdgeInsets.only(left: 20, right: 20),
      OnDialogDismissCall? dismissCall}) {
    var entry = DialogEntry();
    var dialogPanel = _MessageDialogPanel(
      backgroundColor: backgroundColor,
      title: title,
      message: message,
      contentView: contentView,
      buttonArgs: buttonArgs,
      buttonPressed: buttonPressed,
      dialogEntry: entry,
      messageAlign: textAlign,
      padding: padding ?? EdgeInsets.only(left: 20, top: title.isEmptyString ? 25 : 16, right: 20, bottom: 25),
      isShowClose: isShowClose,
    );
    var dialog = DialogPanel.showMessageDialog(context,
        container: dialogPanel,
        borderRadius: borderRadius,
        barrierDismissible: isClickOutsideDismiss,
        dismissCall: dismissCall,
        gravity: gravity,
        margin: margin);
    entry.dialog = dialog;
    if (buildCall != null) {
      buildCall(dialog);
    }
    return dialog;
  }

  /// 显示列表样式dialog
  /// [context] widget context
  /// [backgroundColor] dialog背景颜色
  /// [borderRadius] 边框圆角大小
  /// [isClickOutsideDismiss] 点击dialog外部是否消失
  /// [itemPressed] 列表元素单击监听
  /// [dx] x方向上的偏移量
  /// [dy] y方向上的偏移量
  /// [buildCall] 构建完成回调
  YYDialog showListDialog(BuildContext context,
      {Color backgroundColor = Colors.white,
      double borderRadius = 6,
      bool isClickOutsideDismiss = false,
      List<ListItem> items = const <ListItem>[],
      OnListItemPressed? itemPressed,
      OnDialogBuildCall? buildCall,
      Gravity? gravity,
      double dx = 0,
      double dy = 0,
      OnDialogDismissCall? dismissCall}) {
    var entry = DialogEntry();
    var dialogPanel = _ListDialogPanel(
      backgroundColor: backgroundColor,
      items: items,
      itemPressed: itemPressed,
      dialogEntry: entry,
    );
    var dialog = DialogPanel.showMessageDialog(context,
        container: dialogPanel,
        borderRadius: borderRadius,
        barrierDismissible: isClickOutsideDismiss,
        dismissCall: dismissCall,
        gravity: gravity,
        dx: dx,
        dy: dy);
    entry.dialog = dialog;
    if (buildCall != null) {
      buildCall(dialog);
    }
    return dialog;
  }

  /// 显示顶部浮动组件
  /// [context] widget context
  /// [contentView] 组件视图
  /// [margin] 外边距
  FloatingPanel showTopFloatingWidget(
      {required BuildContext context,
      required Widget contentView,
      EdgeInsetsGeometry? margin,
      Color? backgroundColor}) {
    var floatingPanel = FloatingPanel();
    floatingPanel.show(context, contentView, margin: margin, backgroundColor: backgroundColor);
    return floatingPanel;
  }
}

class _ListDialogPanel extends StatelessWidget {
  /// 背景颜色(默认白色)
  final Color? backgroundColor;

  final List<ListItem>? items;

  final OnListItemPressed? itemPressed;

  final DialogEntry? dialogEntry;

  const _ListDialogPanel({Key? key, this.backgroundColor, this.items, this.itemPressed, this.dialogEntry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: combItems(),
      ),
    );
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      indent: 0.0,
      color: Color(0xffefefef),
    );
  }

  Widget buildItem(ListItem item) {
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      onPressed: () {
        dialogEntry?.dialog?.dismiss();
        if (itemPressed != null) {
          itemPressed!(item);
        }
      },
      child: Container(
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(borderRadius: BorderRadius.zero),
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Text(
          item.text ?? "",
          style: TextStyle(fontSize: 16, letterSpacing: 0.77, color: Color(0xff222222)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> combItems() {
    List<Widget> lst = [];
    if (items.isNotEmptyList) {
      var len = items?.length??0;
      for (var i = 0; i < len; i++) {
        if (i > 0) {
          lst.add(buildDivider());
        }
        var element = items![i];
        lst.add(buildItem(element));
      }
    }
    return lst;
  }
}

class _MessageDialogPanel extends StatelessWidget {
  /// 背景颜色(默认白色)
  final Color backgroundColor;

  /// 标题
  final String? title;

  /// 消息
  final String? message;

  /// 自定义视图
  final Widget? contentView;

  /// 内容对齐(有标题默认居中，无标题默认居左)
  final TextAlign? messageAlign;

  /// 按钮标识(标识顺序为按钮从左到右顺序)
  final List<ButtonArgs> buttonArgs;

  /// 操作项回调事件
  final OnButtonPressed? buttonPressed;

  final DialogEntry? dialogEntry;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 是否显示关闭按钮
  final bool isShowClose;

  _MessageDialogPanel(
      {this.backgroundColor = Colors.white,
      this.title,
      this.message,
      this.contentView,
      this.buttonArgs = const <ButtonArgs>[],
      this.messageAlign,
      this.buttonPressed,
      this.dialogEntry,
      this.padding,
      this.isShowClose = false})
      : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: combColumn(),
      ),
    );
  }

  Widget buildTitle() {
    return Container(
      height: 42,
      color: Colors.transparent,
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Stack(
        children: [
          Text(
            title ?? "",
            style: TextStyle(fontSize: 16, color: Color(0xff222222), letterSpacing: 0.82, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          (isShowClose)
              ? GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(30, 2, 30, 2),
                    child: Icon(
                      Icons.close,
                      color: Color(0xffC8CACC),
                      size: 22,
                    ),
                  ),
                  onTap: () {
                    dialogEntry?.dialog?.dismiss();
                  },
                )
              : Stack(),
        ],
      ),
    );
  }

  Widget buildContent() {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.only(left: 20, top: title.isEmptyString ? 25 : 16, right: 20, bottom: 25),
      color: Colors.transparent,
      child: message.isEmptyString
          ? (contentView ?? Container())
          : Text(
              message ?? "",
              style: TextStyle(
                  fontSize: 16,
                  color: title.isEmptyString ? Color(0xff222222) : Color(0xff666666),
                  letterSpacing: 0.77),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              textAlign: contentAlign(),
            ),
    );
  }

  TextAlign? contentAlign() {
    if (title.isEmptyString) {
      return messageAlign == null ? TextAlign.left : messageAlign;
    } else {
      return messageAlign == null ? TextAlign.center : messageAlign;
    }
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      indent: 0.0,
      color: Color(0xffefefef),
    );
  }

  Widget buildVerDivider() {
    return VerticalDivider(
      indent: 0.0,
      width: 1,
      color: Color(0xffefefef),
    );
  }

  Widget buildButtonsView() {
    return Container(
      height: 45,
      color: Colors.transparent,
      padding: EdgeInsets.all(0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: combButton(),
      ),
    );
  }

  Widget buildButton(ButtonArgs buttonArgs) {
    return Expanded(
      flex: 1,
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: () {
          dialogEntry?.dialog?.dismiss();
          if (buttonPressed != null) {
            buttonPressed!(buttonArgs);
          }
        },
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.zero),
          child: Text(
            buttonArgs.text,
            style: TextStyle(
                fontSize: 16,
                fontWeight: buttonArgs.isBold ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 0.77,
                color: buttonArgs.color ?? Color(0xFF999999)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget buildSqStyleButton(ButtonArgs buttonArgs, double paddingLeft, double paddingRight) {
    return Expanded(
      flex: 1,
      child: Container(
        height: 40,
        padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
        child: FlatButton(
          onPressed: () {
            dialogEntry?.dialog?.dismiss();
            if (buttonPressed != null) {
              buttonPressed!(buttonArgs);
            }
          },
          child: Text(
            buttonArgs.text,
            style: TextStyle(fontSize: 16, letterSpacing: 0.77, color: buttonArgs.color ?? Color(0xFF999999)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  List<Widget> combColumn() {
    List<Widget> lst = [];
    if (title.isNotEmptyString) {
      lst.add(buildTitle());
    }
    lst.add(buildContent());
    if (buttonArgs.isNotEmptyList) {
      lst.add(buildDivider());
      lst.add(buildButtonsView());
    }
    return lst;
  }

  List<Widget> combButton() {
    List<Widget> lst = [];
    var len = buttonArgs.length;
    for (var i = 0; i < len; i++) {
      var element = buttonArgs[i];
      if (i > 0) {
        lst.add(buildVerDivider());
      }
      lst.add(buildButton(element));
    }
    return lst;
  }
}
