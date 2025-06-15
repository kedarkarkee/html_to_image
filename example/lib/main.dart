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
  int currentLayoutStrategy = 0;
  int currentCaptureStrategy = 0;
  bool useDeviceScaleFactor = false;

  static const layoutStrategies = [
    (0, 'Device Default'),
    (1, 'Dimensions (400 x 600)'),
    (2, 'A4 (210mm x 297mm)'),
    (3, 't80 (Thermal 80mm)'),
  ];

  LayoutStrategy _getLayoutStrategy() {
    if (currentLayoutStrategy == 0) return const LayoutStrategy.deviceDefault();
    if (currentLayoutStrategy == 1) {
      return const LayoutStrategy.withDimensions(
        width: 400,
        height: 600,
      );
    }
    if (currentLayoutStrategy == 2) {
      return const LayoutStrategy.a4();
    }
    return const LayoutStrategy.a5();
  }

  static const captureStrategies = [
    (0, 'Follow Layout'),
    (1, 'Dimensions (300 x 300)'),
    (2, 'Unbounded width and height'),
    (3, 'Custom JS (Fit Content)'),
    (4, 'Custom JS (Full Scroll)'),
  ];

  CaptureStrategy _getCaptureStrategy() {
    if (currentCaptureStrategy == 0) {
      return const CaptureStrategy.followLayout();
    }
    if (currentCaptureStrategy == 1) {
      return const CaptureStrategy.withDimensions(
        width: 300,
        height: 300,
      );
    }
    if (currentCaptureStrategy == 2) {
      return const CaptureStrategy.unbounded();
    }
    if (currentCaptureStrategy == 3) return const CaptureStrategy.fitContent();
    return const CaptureStrategy.fullScroll();
  }

  static const _dummyContent = '''
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>300 List Items</title>
      <style>
          body {
              font-family: Arial, sans-serif;
              margin: 20px;
          }
          #itemListContainer {
              border: 1px solid #ccc;
              padding: 10px;
          }
          ul {
              list-style: none;
              padding: 0;
              margin: 0;
          }
          li {
              padding: 8px 0;
              border-bottom: 1px dashed #eee;
          }
          li:last-child {
              border-bottom: none;
          }
      </style>
  </head>
  <body>
      <h1>List of 300 Items</h1>
      <div id="itemListContainer">
          <ul id="myList">
              </ul>
      </div>

      <script>
          document.addEventListener('DOMContentLoaded', function() {
              const list = document.getElementById('myList');
              const numberOfItems = 300;

              for (let i = 1; i <= numberOfItems; i++) {
                  const listItem = document.createElement('li');
                  listItem.textContent = `List Item Number \${i}`;
                  list.appendChild(listItem);
              }
          });
      </script>
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

  Future<void> convertToImage() async {
    final image = await HtmlToImage.tryConvertToImage(
      content: _controller.text,
      layoutStrategy: _getLayoutStrategy(),
      captureStrategy: _getCaptureStrategy(),
      useDeviceScaleFactor: useDeviceScaleFactor,
    );
    setState(() {
      img = image;
    });
  }

  Future<void> convertToImageFromAsset() async {
    final image = await HtmlToImage.convertToImageFromAsset(
      asset: 'assets/invoice.html',
      layoutStrategy: _getLayoutStrategy(),
      captureStrategy: _getCaptureStrategy(),
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Layout Strategy:'),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: DropdownButton(
                                value: currentLayoutStrategy,
                                items: [
                                  for (final (i, s) in layoutStrategies)
                                    DropdownMenuItem(
                                      value: i,
                                      child: Text(s),
                                    )
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    currentLayoutStrategy = v;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Capture Strategy:'),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: DropdownButton(
                                value: currentCaptureStrategy,
                                items: [
                                  for (final (i, s) in captureStrategies)
                                    DropdownMenuItem(
                                      value: i,
                                      child: Text(s),
                                    )
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    currentCaptureStrategy = v;
                                  });
                                },
                              ),
                            ),
                          ),
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
