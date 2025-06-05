import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

import 'package:html_to_image/html_to_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TextEditingController _controller;
  Uint8List? img;
  int currentStrategy = 0;
  bool useDeviceScaleFactor = true;

  static const strategies = [
    (0, 'Auto'),
    (1, 'Constant'),
    (2, 'Fit'),
    (3, 'Full'),
  ];

  static const _dummyContent = '''
  <html>
  <head>
  <title>
  Example of Paragraph tag
  </title>
  </head>
  <body>
  <p> <!-- It is a Paragraph tag for creating the paragraph -->
  <b> HTML </b> stands for <i> <u> Hyper Text Markup Language. </u> </i> It is used to create a web pages and applications. This language
  is easily understandable by the user and also be modifiable. It is actually a Markup language, hence it provides a flexible way for designing the
  web pages along with the text.
  <img src="https://picsum.photos/200/300" />
  <br />
  </body>
  </html>
  ''';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _dummyContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  HtmlDimensionStrategy _getStrategy() {
    if (currentStrategy == 0) return const HtmlDimensionStrategy.auto();
    if (currentStrategy == 1) {
      return const HtmlDimensionStrategy.withDimensions(
        width: 300,
        height: 800,
      );
    }
    if (currentStrategy == 2) return const HtmlDimensionStrategy.fitContent();
    return const HtmlDimensionStrategy.fullScroll();
  }

  Future<void> convertToImage() async {
    final image = await HtmlToImage.tryConvertToImage(
      content: _controller.text,
      dimensionStrategy: _getStrategy(),
      useDeviceScaleFactor: useDeviceScaleFactor,
    );
    setState(() {
      img = image;
    });
  }

  Future<void> convertToImageFromAsset() async {
    final image = await HtmlToImage.convertToImageFromAsset(
      asset: 'assets/invoice.html',
      dimensionStrategy: _getStrategy(),
      useDeviceScaleFactor: useDeviceScaleFactor,
    );
    setState(() {
      img = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('HTML to Image Converter'),
          ),
          body: img == null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: 100,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final (i, s) in strategies)
                            Row(
                              children: [
                                Radio<int>(
                                  value: i,
                                  groupValue: currentStrategy,
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() {
                                      currentStrategy = v;
                                    });
                                  },
                                ),
                                Text(s)
                              ],
                            )
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: useDeviceScaleFactor,
                        title: const Text('Use Device Scale Factor'),
                        onChanged: (v) {
                          setState(() {
                            useDeviceScaleFactor = v ?? useDeviceScaleFactor;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: convertToImage,
                            child: const Text('Convert to Image'),
                          ),
                          ElevatedButton(
                            onPressed: convertToImageFromAsset,
                            child: const Text('Convert from Asset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : _ImageView(image: img!),
          floatingActionButton: img != null
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      img = null;
                    });
                  },
                  tooltip: 'Clear',
                  child: const Icon(Icons.clear),
                )
              : null,
        ),
      ),
    );
  }
}

class _ImageView extends StatefulWidget {
  final Uint8List image;

  const _ImageView({required this.image});
  @override
  State<_ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<_ImageView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: decodeImageFromList(widget.image),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              Expanded(child: Image.memory(widget.image)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Image Size: ${data.width}x${data.height}'),
              ),
            ],
          );
        });
  }
}
