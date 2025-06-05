import 'package:flutter/services.dart';

import 'html_to_image_platform_interface.dart';
import 'config/config.dart';

export 'config/config.dart';

class HtmlToImage {
  /// Converts the given HTML asset file to an image.
  ///
  /// [asset] Asset path to HTML file
  ///
  /// [delay] The delay before taking the snapshot.
  /// This is useful when the content has animations, images or other dynamic content.
  ///
  /// [width] Required width of the image.
  ///
  /// [margins] Represents the margins for an output image.
  static Future<Uint8List> convertToImageFromAsset({
    required String asset,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
    bool useDeviceScaleFactor = true,
    HtmlDimensionStrategy dimensionStrategy =
        const HtmlDimensionStrategy.auto(),
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) async {
    final content = await rootBundle.loadString(asset);
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      delay: delay,
      margins: margins,
      useDeviceScaleFactor: useDeviceScaleFactor,
      dimensionStrategy: dimensionStrategy,
      webViewConfiguration: webViewConfiguration,
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
  ///
  /// [margins] Represents the margins for an output image.
  static Future<Uint8List> convertToImage({
    required String content,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
    bool useDeviceScaleFactor = true,
    HtmlDimensionStrategy dimensionStrategy =
        const HtmlDimensionStrategy.auto(),
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) {
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      delay: delay,
      margins: margins,
      useDeviceScaleFactor: useDeviceScaleFactor,
      dimensionStrategy: dimensionStrategy,
      webViewConfiguration: webViewConfiguration,
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
  ///
  /// [margins] Represents the margins for an output image.
  static Future<Uint8List?> tryConvertToImage({
    required String content,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
    bool useDeviceScaleFactor = true,
    HtmlDimensionStrategy dimensionStrategy =
        const HtmlDimensionStrategy.auto(),
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) async {
    try {
      return await HtmlToImagePlatform.instance.convertToImage(
        content: content,
        delay: delay,
        margins: margins,
        useDeviceScaleFactor: useDeviceScaleFactor,
        dimensionStrategy: dimensionStrategy,
        webViewConfiguration: webViewConfiguration,
      );
    } catch (_) {
      return null;
    }
  }
}
