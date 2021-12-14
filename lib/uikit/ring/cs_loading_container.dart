import 'dart:async';

import 'package:eyflutter_core/kit/utils/string/string_extension.dart';
import 'package:flutter/material.dart';

class CsLoadingContainer extends StatefulWidget {
  CsLoadingContainer({Key key, this.indicator, this.text, this.animation = true, this.isShowMask = false})
      : super(key: key);

  /// 指示器视图
  final Widget indicator;

  /// 显示文本
  final String text;

  /// 是否处理动画
  final bool animation;

  /// 是否显示遮罩
  final bool isShowMask;

  @override
  CsLoadingContainerState createState() => CsLoadingContainerState();
}

class CsLoadingContainerState extends State<CsLoadingContainer> {
  double _opacity = 0.0;
  Duration _animationDuration;
  String _text;

  @override
  void initState() {
    super.initState();
    _text = widget.text;
    _animationDuration = widget.animation ? const Duration(milliseconds: 300) : const Duration(milliseconds: 0);
    if (widget.animation) {
      Future.delayed(const Duration(milliseconds: 30), () {
        if (!mounted) return;
        setState(() {
          _opacity = 1.0;
        });
      });
    } else {
      setState(() {
        _opacity = 1.0;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void dismiss(Completer completer) {
    _animationDuration = const Duration(milliseconds: 300);
    setState(() {
      _opacity = 0.0;
    });
    Future.delayed(_animationDuration, () {
      completer.complete();
    });
  }

  void updateStatus(String text) {
    setState(() {
      _text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> lst = [];
    if (widget.isShowMask) {
      lst.add(_maskBuilder());
    }
    lst.add(_loadingBuilder());
    return AnimatedOpacity(
      opacity: _opacity,
      duration: _animationDuration,
      child: Stack(
        children: lst,
      ),
    );
  }

  Widget _maskBuilder() {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.4),
      ),
    );
  }

  Widget _loadingBuilder() {
    return Center(
      child: Container(
        height: 60,
        margin: EdgeInsets.only(left: 30, right: 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        constraints: BoxConstraints(
          maxWidth: 200,
          minWidth: 160,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildChildElements(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildElements() {
    List<Widget> lst = [];
    if (widget.indicator != null) {
      lst.add(widget.indicator);
      lst.add(SizedBox(
        width: 10,
      ));
    }
    if (_text.isNotEmptyString) {
      lst.add(Text(
        _text,
        style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.82),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
    }
    return lst;
  }
}
