import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:eyflutter_core/mq/cloud_channel_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Mp4ImageProvider extends ImageProvider<Mp4ImageProvider> {
  /// 图片名称
  final String imageName;
  final String suffix;
  final double scale;

  String mp4ImageProviderMethodName = "3cf4e84a8e61d381";

  Mp4ImageProvider({this.imageName, this.suffix, this.scale = 1});

  @override
  ImageStreamCompleter load(Mp4ImageProvider key, decode) {
    return MultiFrameImageStreamCompleter(codec: _loadAsync(key), scale: key.scale);
  }

  Future<T> getNativeImage<T>(String imageName, String suffix) {
    return CloudChannelManager.instance.channel
        .invokeMethod<T>(mp4ImageProviderMethodName, {"imageName": imageName, "suffix": suffix});
  }

  Future<Codec> _loadAsync(Mp4ImageProvider key) async {
    Uint8List bytes = await getNativeImage<Uint8List>(imageName, suffix);
    return instantiateImageCodec(bytes);
  }

  @override
  Future<Mp4ImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<Mp4ImageProvider>(this);
  }
}
