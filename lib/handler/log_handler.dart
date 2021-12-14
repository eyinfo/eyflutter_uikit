import 'package:eyflutter_core/log/beans/log_event.dart';
import 'package:eyflutter_core/log/events/i_log_listener.dart';

class LogHandler implements ILogListener {
  @override
  void onLogListener(Future<LogEvent> logFuture) {
    //拦截输出日志
  }
}
