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
    Duration delay = const Duration(milliseconds: 200),
    int? width,
  }) async {
    final Map<String, dynamic> arguments = {
      'content': content,
      'delay': delay.inMilliseconds,
      'width': width,
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
