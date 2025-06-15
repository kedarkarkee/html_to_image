import 'package:flutter/services.dart';

import 'html_to_image_platform_interface.dart';
import 'config/config.dart';

export 'config/config.dart';

class HtmlToImage {
  /// Converts the given HTML asset file to an image.
  ///
  /// [asset] Asset path to HTML file
  ///
  /// {@macro html_to_image}
  static Future<Uint8List> convertToImageFromAsset({
    required String asset,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
    bool useDeviceScaleFactor = false,
    LayoutStrategy layoutStrategy = const LayoutStrategy.deviceDefault(),
    CaptureStrategy captureStrategy = const CaptureStrategy.followLayout(),
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) async {
    final content = await rootBundle.loadString(asset);
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      delay: delay,
      margins: margins,
      useDeviceScaleFactor: useDeviceScaleFactor,
      layoutStrategy: layoutStrategy,
      captureStrategy: captureStrategy,
      webViewConfiguration: webViewConfiguration,
    );
  }

  /// Converts the given HTML content to an image.
  ///
  /// [content] Plain HTML content
  ///
  /// {@template html_to_image}
  /// [delay] The delay before taking the snapshot.
  /// This is useful when the content has animations, images or other dynamic content.
  ///
  /// [margins] Represents the margins for an output image.
  ///
  /// [useDeviceScaleFactor] Whether to use the device's scale factor when calculating the image size.
  ///
  /// Note that the image on iOS is already scaled by default and enabling this will further scale it by device scale factor
  ///
  /// [layoutStrategy] Defines strategy on how to layout the content on WebView
  ///
  /// [captureStrategy] Defines strategy on how to capture the content that already laid out on WebView
  ///
  /// [webViewConfiguration] Defines configuration for WebView
  ///
  /// {@endtemplate}
  static Future<Uint8List> convertToImage({
    required String content,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
    bool useDeviceScaleFactor = false,
    LayoutStrategy layoutStrategy = const LayoutStrategy.deviceDefault(),
    CaptureStrategy captureStrategy = const CaptureStrategy.followLayout(),
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) {
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      delay: delay,
      margins: margins,
      useDeviceScaleFactor: useDeviceScaleFactor,
      layoutStrategy: layoutStrategy,
      captureStrategy: captureStrategy,
      webViewConfiguration: webViewConfiguration,
    );
  }

  /// Convert the given HTML content to an image and returns null if any error occurs.
  ///
  /// [content] Plain HTML content
  ///
  /// {@macro html_to_image}
  static Future<Uint8List?> tryConvertToImage({
    required String content,
    Duration delay = const Duration(milliseconds: 200),
    ImageMargins margins = const ImageMargins(),
    bool useDeviceScaleFactor = false,
    LayoutStrategy layoutStrategy = const LayoutStrategy.deviceDefault(),
    CaptureStrategy captureStrategy = const CaptureStrategy.followLayout(),
    WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
  }) async {
    try {
      return await HtmlToImagePlatform.instance.convertToImage(
        content: content,
        delay: delay,
        margins: margins,
        useDeviceScaleFactor: useDeviceScaleFactor,
        layoutStrategy: layoutStrategy,
        captureStrategy: captureStrategy,
        webViewConfiguration: webViewConfiguration,
      );
    } catch (_) {
      return null;
    }
  }
}
