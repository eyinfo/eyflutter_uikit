import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:eyflutter_core/mq/cloud_channel_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NativeImageProvider extends ImageProvider<NativeImageProvider> {
  /// 图片名称
  final String imageName;
  final String suffix;
  final double scale;

  /// 是否二进制传输
  final bool isByte;
  String nativeImageProviderMethodName = "nativeImageProvider";

  NativeImageProvider({this.imageName, this.suffix, this.scale = 1, this.isByte});

  @override
  ImageStreamCompleter load(NativeImageProvider key, decode) {
    return MultiFrameImageStreamCompleter(codec: _loadAsync(key), scale: key.scale);
  }

  Future<T> getNativeImage<T>(String imageName, String suffix, bool isByte) {
    return CloudChannelManager.instance.channel
        .invokeMethod<T>(nativeImageProviderMethodName, {"imageName": imageName, "suffix": suffix, "isByte": isByte});
  }

  Future<Codec> _loadAsync(NativeImageProvider key) async {
    if (isByte) {
      Uint8List bytes = await getNativeImage<Uint8List>(imageName, suffix, true);
      return instantiateImageCodec(bytes);
    } else {
      String path = await getNativeImage<String>(imageName, suffix, false);
      var file = File(path);
      return _loadAsyncFromFile(key, file);
    }
  }

  Future<Codec> _loadAsyncFromFile(NativeImageProvider key, File file) {
    assert(key == this);
    final Uint8List bytes = file.readAsBytesSync();
    return instantiateImageCodec(bytes);
  }

  @override
  Future<NativeImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NativeImageProvider>(this);
  }
}
