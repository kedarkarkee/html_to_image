import 'dart:typed_data';

import 'html_to_image_platform_interface.dart';

class HtmlToImage {
  Future<Uint8List> convertToImage({
    required String content,
    double duration = 2000,
    int scale = 3,
    int? width,
  }) {
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      duration: duration,
      scale: scale,
      width: width,
    );
  }

  Future<Uint8List?> tryConvertToImage({
    required String content,
    double duration = 2000,
    int scale = 3,
    int? width,
  }) async {
    try {
      return await HtmlToImagePlatform.instance.convertToImage(
        content: content,
        duration: duration,
        scale: scale,
        width: width,
      );
    } catch (_) {
      return null;
    }
  }
}
