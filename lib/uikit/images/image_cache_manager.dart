import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class ImageCacheManager extends CacheManager {
  static String _key = 'libEsoCachedImageData';

  factory ImageCacheManager() => _getInstance();

  static ImageCacheManager get instance => _getInstance();
  static ImageCacheManager? _instance;

  ImageCacheManager._internal()
      : super(Config(_key,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 100,
            repo: JsonCacheInfoRepository(databaseName: "image_cache_database"),
            fileService: _EsoHttpFileService()));

  static ImageCacheManager _getInstance() {
    return _instance ??= new ImageCacheManager._internal();
  }
}

class _EsoHttpFileService extends FileService {
  HttpClient? _httpClient;

  _EsoHttpFileService({HttpClient? httpClient}) {
    _httpClient = httpClient ?? HttpClient();
    _httpClient?.badCertificateCallback = (cert, host, port) => true;
  }

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final Uri resolved = Uri.base.resolve(url);
    final HttpClientRequest? req = await _httpClient?.getUrl(resolved);
    headers?.forEach((key, value) {
      req?.headers.add(key, value);
    });
    final HttpClientResponse? httpResponse = await req?.close();
    final http.StreamedResponse _response = http.StreamedResponse(
      httpResponse!.timeout(Duration(seconds: 60)),
      httpResponse.statusCode,
      contentLength: httpResponse.contentLength,
      reasonPhrase: httpResponse.reasonPhrase,
      isRedirect: httpResponse.isRedirect,
    );
    return HttpGetResponse(_response);
  }
}
