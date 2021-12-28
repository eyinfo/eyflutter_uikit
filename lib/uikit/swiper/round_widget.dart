import 'package:eyflutter_uikit/uikit/swiper/swiper.dart';
import 'package:flutter/material.dart';

typedef RoundWidgetBuildCallback = void Function(SwiperController controller, RoundListening roundListening);

typedef RoundChangedCallback = void Function(int index);

mixin RoundListening {
  /// 上一个组件
  void previous();

  /// 下一个组件
  void next();

  /// 开始
  void start();

  /// 停止
  void stop();
}

class RoundWidget extends StatefulWidget {
  /// 视图宽高比
  final double? aspectRatio;

  /// 子组件集合
  final List<Widget>? children;

  /// 是否自动播放
  final bool? autoStart;

  /// 部件构建完成回调
  final RoundWidgetBuildCallback? buildCall;

  /// 视图切换回调
  final RoundChangedCallback? changedCall;

  /// Swiper page indicator
  final SwiperIndicator? indicator;

  const RoundWidget(
      {Key? key, this.aspectRatio, this.children, this.autoStart, this.buildCall, this.changedCall, this.indicator})
      : super(key: key);

  @override
  _RoundWidgetState createState() => _RoundWidgetState();
}

class _RoundWidgetState extends State<RoundWidget> with RoundListening {
  SwiperController? _controller;

  @override
  void initState() {
    _controller = SwiperController();
    _controller!.addListener(() {
      if (widget.changedCall != null) {
        widget.changedCall!(_controller!.index);
      }
    });
    if (widget.buildCall != null) {
      widget.buildCall!(_controller!, this);
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? 0,
      child: Swiper(
        children: widget.children,
        controller: _controller,
        autoStart: widget.autoStart ?? true,
        circular: true,
        indicator: widget.indicator,
      ),
    );
  }

  @override
  void next() {
    _controller?.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  void previous() {
    _controller?.previousPage(duration: Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  @override
  void start() {
    _controller?.start();
  }

  @override
  void stop() {
    _controller?.stop();
  }
}
