import 'package:eyflutter_core/eyflutter_core.dart';
import 'package:eyflutter_uikit/uikit/state/lifecycle_state.dart';
import 'package:flutter/material.dart';

abstract class BaseState<T extends StatefulWidget> extends LifecycleState<T> with OnLangChangeState {
  Locale? _locale;

  @override
  void onCreate(BuildContext context, String routeName, Map<String, dynamic> arguments) {
    _locale = Localizations.localeOf(context);
    LangManager.instance.addChangeState(this.hashCode, this);
  }

  @override
  void dispatchLangState(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void onDestroy(String routeName, Map<String, dynamic> arguments) {
    LangManager.instance.removeChangeState(this.hashCode);
  }

  ///在@override#build中调用
  Widget overrideLocalizations({required BuildContext context, required Widget child}) {
    return Localizations.override(
      context: context,
      locale: _locale,
      child: child,
    );
  }
}
