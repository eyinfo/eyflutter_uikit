import 'package:eyflutter_uikit/uikit/images/image_list_factory.dart';

typedef void OnImageSaveButtonCall(String image);
typedef void OnImageSaveCall(bool success, String path, String url);

mixin OnImageFactoryCall {
  ImageListFactory onImageList();
}
