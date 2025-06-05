/// Utility class providing JavaScript snippets for retrieving HTML content dimensions.
class HtmlDimensionStrategy {
  final int? width;
  final int? height;
  final String? script;

  const HtmlDimensionStrategy.auto()
      : width = null,
        height = null,
        script = null;

  const HtmlDimensionStrategy.withDimensions({
    this.width,
    this.height,
  }) : script = null;

  const HtmlDimensionStrategy.fitContent()
      : width = null,
        height = null,
        script = fitContentJs;

  const HtmlDimensionStrategy.fullScroll()
      : width = null,
        height = null,
        script = fullScrollJs;

  const HtmlDimensionStrategy.customScript(this.script)
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
}
