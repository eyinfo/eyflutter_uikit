import 'package:flutter_easyrefresh/easy_refresh.dart';

typedef OnFinishLoadCall = void Function();

class CusRefreshController extends EasyRefreshController {
  final OnFinishLoadCall? finishLoadCall;
  bool isAutoTriggerLoad = true;

  CusRefreshController({this.finishLoadCall});

  @override
  void callRefresh({Duration duration = const Duration(milliseconds: 300)}) {
    super.callRefresh(duration: duration);
  }

  @override
  void callLoad({Duration duration = const Duration(milliseconds: 300)}) {
    super.callLoad(duration: duration);
  }

  @override
  void finishLoad({bool success = true, bool noMore = false}) {
    super.finishLoad(success: success, noMore: noMore);
    if (finishLoadCall != null) {
      finishLoadCall!();
    }
  }
}
