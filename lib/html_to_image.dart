import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'html_to_image_platform_interface.dart';

class HtmlToImage {
  static Future<Uint8List> convertToImageFromAsset({
    required String asset,
    Duration delay = const Duration(milliseconds: 200),
    int? width,
  }) async {
    final content = await rootBundle.loadString(asset);
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      delay: delay,
      width: width,
    );
  }

  static Future<Uint8List> convertToImage({
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

  static Future<Uint8List?> tryConvertToImage({
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
