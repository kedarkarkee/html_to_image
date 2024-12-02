import 'dart:typed_data';

import 'html_to_image_platform_interface.dart';

class HtmlToImage {
  Future<String?> getPlatformVersion() {
    return HtmlToImagePlatform.instance.getPlatformVersion();
  }

  Future<Uint8List> convertToImage(
      {required String content,
      double duration = 2000,
      String? executablePath,
      int scale = 3,
      Map<String, dynamic> args = const {}}) {
    return HtmlToImagePlatform.instance.convertToImage(
      content: content,
      duration: duration,
      executablePath: executablePath,
      scale: scale,
      args: args,
    );
  }
}
