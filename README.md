# html_to_image

Flutter plugin to convert HTML file to image on Android and iOS using WebView.

# Requirements
- Android: Minimum SDK Version 21
- iOS: Minimum Deployment Target 11.0

# Usage

## Convert to Image from HTML content
- ```Future<Uint8List> convertToImage(String content, Duration delay,int? width)```
```dart
final imageBytes = await HtmlToImage.convertToImage(
  content: content,
);
final image = Image.memory(imageBytes);
```

## Convert to Image from HTML asset
- ```Future<Uint8List> convertToImageFromAsset(String asset, Duration delay,int? width)```
```dart
final imageBytes = await HtmlToImage.convertToImageFromAsset(
  asset: 'assets/example.html',
);
final image = Image.memory(imageBytes);
```

- Default delay is 200 milliseconds
- Default width is device width
