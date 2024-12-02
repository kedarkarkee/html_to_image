import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:html_to_image/html_to_image.dart';

const htmlContent = '''
<Html>
<Head>
<title>
Example of Paragraph tag
</title>
</Head>
<Body>
<p> <!-- It is a Paragraph tag for creating the paragraph -->
<b> HTML </b> stands for <i> <u> Hyper Text Markup Language. </u> </i> It is used to create a web pages and applications. This language
is easily understandable by the user and also be modifiable. It is actually a Markup language, hence it provides a flexible way for designing the
web pages along with the text.
</p>
यो नेपाली अक्षर हो
</p>
</Body>
</Html>
''';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _htmlToImagePlugin = HtmlToImage();
  Uint8List? img;

  Future<void> contentToImage() async {
    try {
      final image = await _htmlToImagePlugin.convertToImage(
        content: htmlContent,
      );
      setState(() {
        img = image;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: img == null ? const Text('Nothing here') : Image.memory(img!),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: contentToImage,
          tooltip: 'COnvert',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
