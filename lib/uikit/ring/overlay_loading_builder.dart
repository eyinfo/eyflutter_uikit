import 'dart:async';

import 'package:flutter/widgets.dart';

import 'cs_loading_container.dart';

class OverlayLoadingBuilder {
  OverlayEntry _overlayEntry;
  GlobalKey<CsLoadingContainerState> _key;

  OverlayEntry get overlayEntry => _overlayEntry;

  GlobalKey<CsLoadingContainerState> get key => _key;

  void show(BuildContext context, {String text, Widget indicator}) {
    GlobalKey<CsLoadingContainerState> key = GlobalKey<CsLoadingContainerState>();
    bool _animation = this.overlayEntry == null;
    _remove();

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) => CsLoadingContainer(
        key: key,
        text: text,
        indicator: indicator,
        animation: _animation,
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    _overlayEntry = overlayEntry;
    _key = key;
  }

  void _remove() {
    overlayEntry?.remove();
    _overlayEntry = null;
    _key = null;
  }

  void dismiss({bool animation = true}) async {
    if (animation) {
      CsLoadingContainerState loadingContainerState = key?.currentState;
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
