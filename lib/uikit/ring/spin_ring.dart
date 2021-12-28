import 'dart:math';

import 'package:flutter/material.dart';

import 'cs_ring_painter.dart';

/// 自转环效果
class SpinRing extends StatefulWidget {
  final Color? indicatorBackgroundColor;
  final Color indicatorColor;
  final double size;
  final double lineWidth;
  final Duration duration;
  final AnimationController? controller;

  const SpinRing({
    Key? key,
    required this.indicatorColor,
    this.indicatorBackgroundColor,
    this.lineWidth = 7.0,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1200),
    this.controller,
  });

  @override
  _SpinKitRingState createState() => _SpinKitRingState();
}

class _SpinKitRingState extends State<SpinRing> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation1, _animation2, _animation3;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() => setState(() {}))
      ..repeat();
    _animation1 = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller!, curve: const Interval(0.0, 1.0, curve: Curves.linear)));
    _animation2 = Tween(begin: -2 / 3, end: 1 / 2)
        .animate(CurvedAnimation(parent: _controller!, curve: const Interval(0.5, 1.0, curve: Curves.linear)));
    _animation3 = Tween(begin: 0.25, end: 5 / 6)
        .animate(CurvedAnimation(parent: _controller!, curve: const Interval(0.0, 1.0, curve: SpinRingCurve())));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()..rotateZ((_animation1?.value ?? 0) * 5 * pi / 6),
        alignment: FractionalOffset.center,
        child: SizedBox.fromSize(
          size: Size.square(widget.size),
          child: CustomPaint(
            foregroundPainter: CsRingPainter(
              paintWidth: widget.lineWidth,
              trackColor: widget.indicatorBackgroundColor ?? Colors.transparent,
              progressPercent: (_animation3?.value ?? 0),
              startAngle: pi * (_animation2?.value ?? 0),
            ),
            painter: CsRingPainter(
              paintWidth: widget.lineWidth,
              trackColor: widget.indicatorColor,
              progressPercent: 100,
              startAngle: pi * 0,
            ),
          ),
        ),
      ),
    );
  }
}

class SpinRingCurve extends Curve {
  const SpinRingCurve();

  @override
  double transform(double t) => (t <= 0.5) ? 2 * t : 2 * (1 - t);
}
