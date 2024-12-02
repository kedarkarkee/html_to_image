import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:html_to_image/html_to_image.dart';
import 'package:html_to_image/html_to_image_platform_interface.dart';
import 'package:html_to_image/html_to_image_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHtmlToImagePlatform
    with MockPlatformInterfaceMixin
    implements HtmlToImagePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Uint8List> convertToImage(
      {required String content,
      double duration = 2000,
      String? executablePath,
      int scale = 3,
      Map<String, dynamic> args = const {}}) {
    // TODO: implement contentToImage
    throw UnimplementedError();
  }
}

void main() {
  final HtmlToImagePlatform initialPlatform = HtmlToImagePlatform.instance;

  test('$MethodChannelHtmlToImage is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHtmlToImage>());
  });

  test('getPlatformVersion', () async {
    HtmlToImage htmlToImagePlugin = HtmlToImage();
    MockHtmlToImagePlatform fakePlatform = MockHtmlToImagePlatform();
    HtmlToImagePlatform.instance = fakePlatform;

    expect(await htmlToImagePlugin.getPlatformVersion(), '42');
  });
}
