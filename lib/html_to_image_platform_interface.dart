import 'dart:typed_data';

import 'package:html_to_image/config.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'html_to_image_method_channel.dart';

abstract class HtmlToImagePlatform extends PlatformInterface {
  /// Constructs a HtmlToImagePlatform.
  HtmlToImagePlatform() : super(token: _token);

  static final Object _token = Object();

  static HtmlToImagePlatform _instance = MethodChannelHtmlToImage();

  /// The default instance of [HtmlToImagePlatform] to use.
  ///
  /// Defaults to [MethodChannelHtmlToImage].
  static HtmlToImagePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HtmlToImagePlatform] when
  /// they register themselves.
  static set instance(HtmlToImagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Uint8List> convertToImage({
    required String content,
    required Duration delay,
    required ImageMargins margins,
    required HtmlDimensionStrategy dimensionStrategy,
  }) {
    throw UnimplementedError('contentToImage() has not been implemented.');
  }
}
