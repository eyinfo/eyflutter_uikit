import 'package:eyflutter_uikit/uikit/ring/spin_ring.dart';
import 'package:flutter/material.dart';

class RefreshDefaultWidget {
  double firstViewIndicatorSize = 116;

  Widget _buildRing(double size) {
    return SpinRing(
      indicatorColor: Color(0xffb5bdc8),
      indicatorBackgroundColor: Color(0xffe2e5e9),
      size: size,
      lineWidth: 2,
      duration: Duration(milliseconds: 1400),
    );
  }

  Widget firstRefreshWidget() {
    return AnimatedOpacity(
      opacity: 0.8,
      duration: Duration(milliseconds: 0),
      child: Stack(
        children: <Widget>[
          Align(
              child: Container(
            width: firstViewIndicatorSize,
            height: firstViewIndicatorSize,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildChildElements(),
              ),
            ),
          ))
        ],
      ),
    );
  }

  Widget _firstWidgetIndicator() {
    double _size = 42;
    return Stack(
      children: <Widget>[
        Align(
          child: _buildRing(_size),
        ),
        Positioned(
          left: (firstViewIndicatorSize - 18) / 2,
          top: (_size - 18) / 2,
          child: Icon(
            Icons.refresh,
            color: Color(0xffE2E5E9),
            size: 18,
          ),
        )
      ],
    );
  }

  List<Widget> _buildChildElements() {
    List<Widget> lst = [];
    lst.add(_firstWidgetIndicator());
    lst.add(Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        "加载中...",
        style:
            TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 0.82),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ));
    return lst;
  }
}
