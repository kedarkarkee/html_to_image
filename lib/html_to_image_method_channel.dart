import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'config/config.dart';
import 'html_to_image_platform_interface.dart';

/// An implementation of [HtmlToImagePlatform] that uses method channels.
class MethodChannelHtmlToImage extends HtmlToImagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('html_to_image');

  @override
  Future<Uint8List> convertToImage({
    required String content,
    required Duration delay,
    required ImageMargins margins,
    required bool useDeviceScaleFactor,
    required LayoutStrategy layoutStrategy,
    required HtmlDimensionStrategy dimensionStrategy,
    required WebViewConfiguration webViewConfiguration,
  }) async {
    final Map<String, dynamic> arguments = {
      'content': content,
      'delay': delay.inMilliseconds,
      'layout_strategy': layoutStrategy.toMap(),
      'width': dimensionStrategy.width,
      'height': dimensionStrategy.height,
      'margins': [
        margins.left,
        margins.top,
        margins.right,
        margins.bottom,
      ],
      'use_device_scale_factor': useDeviceScaleFactor,
      'dimension_script': dimensionStrategy.script,
      'web_view_configuration': webViewConfiguration.toMap(),
    };
    try {
      final result = await (methodChannel.invokeMethod(
          'convertToImage', arguments)) as Uint8List;
      return result;
    } on Exception catch (e) {
      throw Exception("Error: $e");
    }
  }
}
