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

  Future<void> convertToImage() async {
    final image = await HtmlToImage.tryConvertToImage(
      content: _controller.text,
    );
    setState(() {
      img = image;
    });
  }

  Future<void> convertToImageFromAsset() async {
    final image = await HtmlToImage.convertToImageFromAsset(
      asset: 'assets/example.html',
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
              : Image.memory(img!),
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
