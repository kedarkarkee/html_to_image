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
  final _htmlToImagePlugin = HtmlToImage();
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

  Future<void> contentToImage() async {
    final image = await _htmlToImagePlugin.tryConvertToImage(
      content: _controller.text,
    );
    setState(() {
      img = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HTML to Image Converter'),
        ),
        body: img == null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  maxLines: 100,
                ),
              )
            : Image.memory(img!),
        floatingActionButton: img == null
            ? FloatingActionButton(
                onPressed: contentToImage,
                tooltip: 'Convert to Image',
                child: const Icon(Icons.play_arrow),
              )
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    img = null;
                  });
                },
                tooltip: 'Clear',
                child: const Icon(Icons.clear),
              ),
      ),
    );
  }
}
