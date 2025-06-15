# HTML to Image

A fully customizable plugin to convert HTML file to image on Android and iOS using WebView.

# Requirements
- Android: Minimum SDK Version 21
- iOS: Minimum Deployment Target 11.0

# Usage

## Convert to Image from HTML content
- ```convertToImage```
```dart
final imageBytes = await HtmlToImage.instance.convertToImage(
  content: content,
);
final image = Image.memory(imageBytes);
```

## Convert to Image from HTML asset
- ```convertToImageFromAsset```
```dart
final imageBytes = await HtmlToImage.instance.convertToImageFromAsset(
  asset: 'assets/example.html',
);
final image = Image.memory(imageBytes);
```

## Configuring Delay
Delay is useful when the content has animations, images or other dynamic content that takes time to render
```dart
final imageBytes = await HtmlToImage.instance.convertToImage(
  content: content,
  delay: const Duration(milliseconds: 500), // Default is 200 milliseconds
);
final image = Image.memory(imageBytes);
```

## Layouting the WebView
Layout of the webview can be configured through `LayoutStrategy`
```dart
final imageBytes = await HtmlToImage.instance.convertToImage(
  content: content,
  layoutStrategy: LayoutStrategy.withDimensions(
    width: 400,
    height: 500,
  ), // Default is LayoutStrategy.deviceDefault() which uses device width and height to layout
);
final image = Image.memory(imageBytes);
```

## Configuring dimensions of the Output Image
Dimensions of the output image can be configured through `CaptureStrategy`
```dart
final imageBytes = await HtmlToImage.instance.convertToImage(
  content: content,
  layoutStrategy: LayoutStrategy.deviceDefault(),
  captureStrategy: CaptureStrategy.withDimensions(
    width: 400,
    height: 500,
  ), // Default is CaptureStrategy.followLayout() which generates the image as the same dimensions as its layout
);
final image = Image.memory(imageBytes);
```
To capture the image with unbounded dimensions
```dart
captureStrategy: CaptureStrategy.unbounded() // Captures full width and height of the webview content
```
```dart
// Width or Height can be set to -1 to make the respective dimension unbounded
captureStrategy: CaptureStrategy.withDimensions(
  width: 300,
  height: -1
) // Makes the height unbounded but width constant to 300px
```
```dart
captureStrategy: CaptureStrategy.withDimensions(
  width: -1,
  height: 500,
) // Makes the width unbounded but height constant to 500px
```

Using Custom JavaScript to calculate content dimensions
```dart
captureStrategy: CaptureStrategy.fitContent() // Uses a JavaScript to calculate the bounding rects to get as minimum dimensions required to capture content. (No accuracy is guaranteed)
```
```dart
captureStrategy: CaptureStrategy.fitHeight() // Uses a JavaScript to calculate the bounding rects to get as minimum height required to capture content (No accuracy is guaranteed). The width will be followed as the layout width.
```
```dart
captureStrategy: CaptureStrategy.fullScroll() // Uses a JavaScript to calculate the full scroll dimensions required to capture content. (No accuracy is guaranteed)
```
```dart
// Custom script can also be provided to dynamically calculate the width and height
//
// The script must return an array of two elements with javascript numbers
//
// Returning 0 for width and height will make the width or height follow the layout
//
// Returning -1 for width or height will make the width or height unbounded
captureStrategy: CaptureStrategy.customScript(
  """
  (function() {
   let maxRight = 0;

    document.body.querySelectorAll('*').forEach(el => {
    const rect = el.getBoundingClientRect();
    maxRight = Math.max(maxRight, rect.right);
    });

    return [maxRight, 0];
    })(); // Calculate the maximum right position of all elements in the document body
    // The height will be followed as the layout since its value is 0
  """
)
```
## Using Custom Margins to Output Image
Custom margins can be applied using `ImageMargins` property
```dart
final imageBytes = await HtmlToImage.instance.convertToImage(
  content: content,
  margins: const ImageMargins.all(20), // Applies 20px margins on all sides
);
final image = Image.memory(imageBytes);
```
## Using Custom Web View Configuration
WebView can be configured as required
```dart
final imageBytes = await HtmlToImage.instance.convertToImage(
  content: content,
  webViewConfiguration: WebViewConfiguration(
    javaScriptEnabled: true, // Enables JavaScript execution
    javaScriptCanOpenWindowsAutomatically: false,
    // The above two configurations will apply to both android and iOS
    androidWebViewConfiguration: AndroidWebViewConfiguration(
      enableSlowWholeDocumentDraw: true,
      useWideViewPort: true,
      loadWithOverviewMode: true,
      setSupportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,
      layoutAlgorithm: AndroidWebViewLayoutAlgorithm.normal,
    ) // Android specific webview configuration
  ) // Ios Specific configuration is not available
);
final image = Image.memory(imageBytes);
```
## Using Device Scale Factor
Output image can be scaled to device scale factor for clarity

*Note that, due to the difference in how Android and iOS handle measurements, the webview is already scaled on iOS by default and enabling this toggle will further scale it.
For e.g. with the config `layoutStrategy: LayoutStrategy.a4()`, `captureStrategy: CaptureStrategy.followLayout()` and `useDeviceScaleFactor: false`, the output on android is `595 × 842 pixels` whereas on Iphone 16 Plus (scale factor of 3), its `1785 x 2526` i.e. scaled by 3 times.*
```dart
final imageBytes = await HtmlToImage.instance.convertToImage(
  content: content,
  useDeviceScaleFactor: true, // Scales the output image by device scale factor
);
final image = Image.memory(imageBytes);
```

### Reporting Issues
If you encounter any issues or have suggestions for improvement, please open an issue on the [GitHub repository](https://github.com/kedarkarkee/html_to_image/issues).
