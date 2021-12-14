import 'package:eyflutter_uikit/uikit/ring/spin_ring.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum LoadingType {
  //经典(菊花类型)
  classic,
  //环类型
  ring,
  //图标-环类型
  iconRing
}

class IconRingIndicator extends StatefulWidget {
  IconRingIndicator({
    Key key,
    @required this.size,
    this.indicatorColor: const Color(0xffb5bdc8),
    this.indicatorBackgroundColor: const Color(0xffe2e5e9),
    this.loadingType,
    this.icon,
  }) : super(key: key);

  /// 指示器大小
  final double size;

  /// 指示器颜色
  final Color indicatorColor;

  /// 指示器背景颜色
  final Color indicatorBackgroundColor;

  /// 加载类型
  final LoadingType loadingType;

  /// 图标(指示器中间显示)
  final Icon icon;

  @override
  State<StatefulWidget> createState() => _IconRingIndicatorState();
}

class _IconRingIndicatorState extends State<IconRingIndicator> {
  double _size;

  @override
  void initState() {
    _size = widget.size;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _size,
      ),
      child: _combIndicator(),
    );
  }

  Widget _combIndicator() {
    if (widget.loadingType == LoadingType.classic) {
      return Theme(
        data: ThemeData(
          cupertinoOverrideTheme: CupertinoThemeData(
            brightness: Brightness.dark,
          ),
        ),
        child: CupertinoActivityIndicator(
          radius: 16,
        ),
      );
    } else if (widget.loadingType == LoadingType.iconRing) {
      return _buildIconRing(_size);
    } else {
      return _buildRing(18);
    }
  }

  Widget _buildRing(double size) {
    return SpinRing(
      indicatorColor: widget.indicatorColor,
      indicatorBackgroundColor: widget.indicatorBackgroundColor,
      size: size,
      lineWidth: 2,
      duration: Duration(milliseconds: 1400),
    );
  }

  Widget _buildIconRing(double _size) {
    return Stack(
      children: <Widget>[
        Align(
          child: _buildRing(_size),
          alignment: Alignment.center,
        ),
        Positioned(
          left: (_size - 8) / 2,
          top: (_size - 8) / 2,
          child: widget.icon ??
              Icon(
                Icons.refresh,
                color: Color(0xffE2E5E9),
                size: 8,
              ),
        )
      ],
    );
  }
}
