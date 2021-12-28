import 'package:eyflutter_uikit/uikit/over_scroll_behavior.dart';
import 'package:flutter/material.dart';

class ScrollVerticalView extends StatelessWidget {
  final Widget? child;

  final ScrollController? controller;

  const ScrollVerticalView({Key? key, this.child, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: OverScrollBehavior(),
      child: SingleChildScrollView(
        controller: controller,
        child: child,
      ),
    );
  }
}
