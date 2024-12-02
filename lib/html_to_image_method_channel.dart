import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'html_to_image_platform_interface.dart';

/// An implementation of [HtmlToImagePlatform] that uses method channels.
class MethodChannelHtmlToImage extends HtmlToImagePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('html_to_image');

  @override
  Future<Uint8List> convertToImage({
    required String content,
    double duration = 2000,
    int scale = 3,
    int? width,
  }) async {
    final Map<String, dynamic> arguments = {
      'content': content,
      'duration': duration,
      'scale': scale,
      'width': width,
    };

    Uint8List results = Uint8List.fromList([]);

    try {
      /// mobile method
      results = await (methodChannel.invokeMethod('convertToImage', arguments));
    } on Exception catch (e) {
      throw Exception("Error: $e");
    }
    return results;
  }
}
