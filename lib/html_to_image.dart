import 'dart:typed_data';

import 'html_to_image_platform_interface.dart';

class HtmlToImage {
  Future<Uint8List> convertToImage({
    required String content,
    Duration delay = const Duration(milliseconds: 200),
    int? width,
  }) {
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      delay: delay,
      width: width,
    );
  }

  Future<Uint8List?> tryConvertToImage({
    required String content,
    Duration delay = const Duration(milliseconds: 200),
    int? width,
  }) async {
    try {
      return await HtmlToImagePlatform.instance.convertToImage(
        content: content,
        delay: delay,
        width: width,
      );
    } catch (_) {
      return null;
    }
  }
}
