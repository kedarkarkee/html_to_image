/// Utility class providing strategy and JavaScript snippets for retrieving output image dimensions
class CaptureStrategy {
  final int? width;
  final int? height;
  final String? script;

  /// Follows the dimensions of the WebView Layout
  const CaptureStrategy.followLayout()
      : width = null,
        height = null,
        script = null;

  /// Uses the provided `width` and `height` as the output dimensions
  ///
  /// Omitting any will fallback to dimensions of WebView Layout
  ///
  /// Passing negative will measure the dimensions and calculate accordingly
  const CaptureStrategy.withDimensions({
    this.width,
    this.height,
  }) : script = null;

  /// Uses a JavaScript to calculate the dimensions
  /// required to fit content width and height
  const CaptureStrategy.fitContent()
      : width = null,
        height = null,
        script = fitContentJs;

  /// Uses a JavaScript to calculate the dimensions
  /// required to fit the content width
  const CaptureStrategy.fitWidth()
      : width = null,
        height = null,
        script = fitWidthJs;

  /// Uses a JavaScript to calculate the dimensions
  /// required to fit the content height
  const CaptureStrategy.fitHeight()
      : width = null,
        height = null,
        script = fitHeightJs;

  /// Uses a JavaScript to calculate the full scroll content dimensions
  const CaptureStrategy.fullScroll()
      : width = null,
        height = null,
        script = fullScrollJs;

  /// Provide a custom script to calculate content dimensions
  ///
  /// The script should return a JavaScript array of numbers where
  /// first element is the width and second element is the height
  ///
  /// The array can also return array of two numbers with either or both values 0
  /// for which the dimensions will fall back to WebView Layout Dimensions
  ///
  /// For example, see [CaptureStrategy.fitContentJs] and [CaptureStrategy.fullScrollJs]
  const CaptureStrategy.customScript(this.script)
      : width = null,
        height = null;

  /// JavaScript code to determine the tightest possible dimensions (width and height)
  /// that encompass all rendered HTML elements. This computes the maximum
  /// `right` and `bottom` coordinates from the `getBoundingClientRect()` of all elements.
  ///
  /// Returns a JavaScript array: `[width, height]`
  static const fitContentJs = """
  (function() {
   let maxRight = 0;
   let maxBottom = 0;

    document.body.querySelectorAll('*').forEach(el => {
    const rect = el.getBoundingClientRect();
    maxRight = Math.max(maxRight, rect.right);
    maxBottom = Math.max(maxBottom, rect.bottom);
    });

    return [maxRight, maxBottom];
    })();
  """;

  /// JavaScript code to determine the tightest possible width
  /// that encompass all rendered HTML elements. This computes the maximum
  /// `right` coordinates from the `getBoundingClientRect()` of all elements.
  ///
  /// Returns a JavaScript array: `[width, height]`
  static const fitWidthJs = """
  (function() {
   let maxRight = 0;

    document.body.querySelectorAll('*').forEach(el => {
    const rect = el.getBoundingClientRect();
    maxRight = Math.max(maxRight, rect.right);
    });

    return [maxRight, 0];
    })();
  """;

  /// JavaScript code to determine the tightest possible height
  /// that encompass all rendered HTML elements. This computes the maximum
  /// `bottom` coordinates from the `getBoundingClientRect()` of all elements.
  ///
  /// Returns a JavaScript array: `[width, height]`
  static const fitHeightJs = """
  (function() {
   let maxBottom = 0;

    document.body.querySelectorAll('*').forEach(el => {
    const rect = el.getBoundingClientRect();
    maxBottom = Math.max(maxBottom, rect.bottom);
    });

    return [0, maxBottom];
    })();
  """;

  /// JavaScript code to determine the maximum potential width and height of the HTML document
  /// by taking the largest values from `scrollWidth`, `offsetWidth`, and `clientWidth`
  /// properties of both `document.body` and `document.documentElement`.
  /// This is useful for capturing the full scrollable content size.
  ///
  /// Returns a JavaScript array: `[totalWidth, totalHeight]`
  static const fullScrollJs = """
  (function() {
      var body = document.body;
      var html = document.documentElement;

      // Get the total width including any overflow
      var totalWidth = Math.max(
          body.scrollWidth, html.scrollWidth,
          body.offsetWidth, html.offsetWidth,
          body.clientWidth, html.clientWidth
      );

      // Get the total height
      var totalHeight = Math.max(
          body.scrollHeight, html.scrollHeight,
          body.offsetHeight, html.offsetHeight,
          body.clientHeight, html.clientHeight
      );

      return [totalWidth, totalHeight];
  })();
""";

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'script': script,
    };
  }
}
