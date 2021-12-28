import 'dart:async';

import 'package:flutter/material.dart';

class FloatingPanel {
  OverlayEntry? _overlayEntry;
  GlobalKey<_TopFloatingWidgetState>? _key;

  GlobalKey<_TopFloatingWidgetState>? get key => _key;

  void show(BuildContext context, Widget contentView, {EdgeInsetsGeometry? margin, Color? backgroundColor}) {
    GlobalKey<_TopFloatingWidgetState> key = GlobalKey<_TopFloatingWidgetState>();
    _remove();
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) => _TopFloatingWidget(
        key: key,
        contentView: contentView,
        margin: margin,
        backgroundColor: backgroundColor,
      ),
    );
    Overlay.of(context)?.insert(overlayEntry);
    _overlayEntry = overlayEntry;
    _key = key;
  }

  void _remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _key = null;
  }

  void dismiss({bool animation = true}) async {
    if (animation) {
      _TopFloatingWidgetState? loadingContainerState = key?.currentState;
      if (loadingContainerState != null) {
        final Completer<void> completer = Completer<void>();
        loadingContainerState.dismiss(completer);
        completer.future.then((value) {
          _remove();
        });
        return;
      }
    }
    _remove();
  }
}

class _TopFloatingWidget extends StatefulWidget {
  final Widget? contentView;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const _TopFloatingWidget({Key? key, this.contentView, this.margin, this.backgroundColor}) : super(key: key);

  @override
  _TopFloatingWidgetState createState() => _TopFloatingWidgetState();
}

class _TopFloatingWidgetState extends State<_TopFloatingWidget> {
  double _opacity = 0.0;
  Duration? _animationDuration;

  @override
  void initState() {
    super.initState();
    _animationDuration = const Duration(milliseconds: 300);
    Future.delayed(const Duration(milliseconds: 30), () {
      if (!mounted) return;
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void dismiss(Completer completer) {
    _animationDuration = const Duration(milliseconds: 300);
    setState(() {
      _opacity = 0.0;
    });
    Future.delayed(_animationDuration!, () {
      completer.complete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _animationDuration!,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
              color: widget.backgroundColor,
              margin: widget.margin,
              child: widget.contentView,
            ),
          )
        ],
      ),
    );
  }
}
