import 'package:flutter/services.dart';
import 'package:html_to_image/config.dart';

import 'html_to_image_platform_interface.dart';

export 'config.dart';

class HtmlToImage {
  /// Converts the given HTML asset file to an image.
  ///
  /// [asset] Asset path to HTML file
  ///
  /// [delay] The delay before taking the snapshot.
  /// This is useful when the content has animations, images or other dynamic content.
  ///
  /// [width] Required width of the image.
  static Future<Uint8List> convertToImageFromAsset({
    required String asset,
    int? width,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
  }) async {
    final content = await rootBundle.loadString(asset);
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      width: width,
      delay: delay,
      margins: margins,
    );
  }

  /// Converts the given HTML content to an image.
  ///
  /// [content] Plain HTML content
  ///
  /// [delay] The delay before taking the snapshot.
  /// This is useful when the content has animations, images or other dynamic content.
  ///
  /// [width] Required width of the image.
  static Future<Uint8List> convertToImage({
    required String content,
    int? width,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
  }) {
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      delay: delay,
      width: width,
      margins: margins,
    );
  }

  /// Convert the given HTML content to an image and returns null if any error occurs.
  ///
  /// [content] Plain HTML content
  ///
  /// [delay] The delay before taking the snapshot.
  /// This is useful when the content has animations, images or other dynamic content.
  ///
  /// [width] Required width of the image.
  static Future<Uint8List?> tryConvertToImage({
    required String content,
    int? width,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
  }) async {
    try {
      return await HtmlToImagePlatform.instance.convertToImage(
        content: content,
        delay: delay,
        width: width,
        margins: margins,
      );
    } catch (_) {
      return null;
    }
  }
}
