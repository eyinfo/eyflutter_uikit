import 'package:flutter/cupertino.dart';

typedef DidSelectIndexCallback = void Function(int index);
typedef DidSelectCancelCallback = void Function();

csShowBottomSheet(
  BuildContext context, {
  String title,
  @required List<String> actions,
  String cancel = '取消',
  DidSelectIndexCallback indexCallback,
  DidSelectCancelCallback cancelCallback,
}) {
  List<Widget> widgets = [];
  actions.asMap().forEach((int index, String value) {
    widgets.add(CupertinoActionSheetAction(
      onPressed: () {
        Navigator.pop(context);
        if (indexCallback != null) {
          indexCallback(index);
        }
      },
      child: Text(value),
    ));
  });
  showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        var sheet = CupertinoActionSheet(
          title: Text(title),
          actions: widgets,
          cancelButton: cancel == null
              ? SizedBox.shrink()
              : CupertinoActionSheetAction(
                  child: Text(cancel),
                  onPressed: () {
                    Navigator.pop(context);
                    if (cancelCallback != null) {
                      cancelCallback();
                    }
                  },
                ),
        );
        return sheet;
      });
}

