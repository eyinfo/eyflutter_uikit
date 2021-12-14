import 'package:eyflutter_core/lang/lang_manager.dart';
import 'package:eyflutter_core/mq/ebus/cloud_ebus.dart';
import 'package:eyflutter_uikit/uikit/state/lifecycle_state.dart';
import 'package:flutter/material.dart';

abstract class BaseState<T extends StatefulWidget> extends LifecycleState<T> {
  Locale _locale;

  /// 更新语言监听
  void onChangedLanguage() {}

  @override
  void onCreate(BuildContext context, String routeName, Map<String, dynamic> arguments) {
    _locale = Localizations.localeOf(context);
    CloudEBus.instance.addEvent(this, action: LangManager.instance.stateAction, method: _changeLocale);
  }

  _changeLocale(Locale locale) {
    onChangedLanguage();
    setState(() {
      _locale = locale;
    });
  }

  @override
  void onDestroy(String routeName, Map<String, dynamic> arguments) {
    CloudEBus.instance.disposeEvent(this, action: LangManager.instance.stateAction);
  }

  ///在@override#build中调用
  Widget overrideLocalizations(BuildContext context, {Widget child}) {
    return Localizations.override(
      context: context,
      locale: _locale,
      child: child,
    );
  }
}
