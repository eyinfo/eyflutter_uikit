import 'package:eyflutter_uikit/uikit/refresh/indicator/cus_refresh_header.dart';
import 'package:eyflutter_uikit/uikit/refresh/refresh_init_manager.dart';

class ClassicRefreshHeader {
  CusRefreshHeader _cusRefreshHeader;

  ClassicRefreshHeader() {
    _cusRefreshHeader = CusRefreshHeader(
        triggerDistance: RefreshInitManager.instance.headerHandler().refreshHeight(),
        height: RefreshInitManager.instance.headerHandler().refreshHeight(),
        enableHapticFeedback: false);
  }

  CusRefreshHeader get header => _cusRefreshHeader;
}
