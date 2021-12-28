import 'package:flutter/material.dart';

class RotationWidget extends StatefulWidget {
  final Widget? child;
  final bool isStartDefault;
  final int speedMilliseconds;

  const RotationWidget({Key? key, this.isStartDefault = true, this.speedMilliseconds = 500, this.child})
      : super(key: key);

  @override
  _RotationWidgetState createState() => _RotationWidgetState();
}

class _RotationWidgetState extends State<RotationWidget> with TickerProviderStateMixin {
  //动画控制器
  AnimationController? controller;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(duration: Duration(milliseconds: widget.speedMilliseconds), vsync: this);
    controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller!.reset();
        controller!.forward();
      }
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.isStartDefault) {
        controller!.forward();
      }
    });
  }

  stop() {
    controller?.stop();
  }

  start() {
    controller?.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget buildRotationTransition() {
    return Center(
      child: RotationTransition(
        //设置动画的旋转中心
        alignment: Alignment.center,
        //动画控制器
        turns: controller!,
        //将要执行动画的子view
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildRotationTransition();
  }

  @override
  void didUpdateWidget(covariant RotationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStartDefault) {
      controller?.forward();
    } else {
      controller?.stop();
    }
  }
}
