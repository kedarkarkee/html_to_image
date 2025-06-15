/// Configuration settings for webview
class WebViewConfiguration {
  /// Whether to enable JavaScript execution in the webview.
  final bool javaScriptEnabled;

  /// Whether to allow JavaScript to open new windows automatically.
  final bool javaScriptCanOpenWindowsAutomatically;

  /// Android specific webview configuration settings.
  ///
  /// Has no effect on iOS.
  final AndroidWebViewConfiguration androidWebViewConfiguration;

  /// Creates an instance of [WebViewConfiguration] with default values.
  const WebViewConfiguration({
    this.javaScriptEnabled = true,
    this.javaScriptCanOpenWindowsAutomatically = false,
    this.androidWebViewConfiguration = const AndroidWebViewConfiguration(),
  });

  Map<String, dynamic> toMap() {
    return {
      'javascript_enabled': javaScriptEnabled,
      'javascript_can_open_windows_automatically':
          javaScriptCanOpenWindowsAutomatically,
      'android_web_view_configuration': androidWebViewConfiguration.toMap(),
    };
  }
}

/// Android specific webview configuration settings.
///
/// Has no effect on iOS.
class AndroidWebViewConfiguration {
  /// Whether to enable slow whole document drawing.
  final bool enableSlowWholeDocumentDraw;

  /// Whether to use wide viewport.
  final bool useWideViewPort;

  /// Whether to load with overview mode.
  final bool loadWithOverviewMode;

  /// Whether to set support zoom.
  final bool setSupportZoom;

  /// Whether to have built-in zoom controls.
  final bool builtInZoomControls;

  /// Whether to display zoom controls.
  final bool displayZoomControls;

  /// The layout algorithm.
  final AndroidWebViewLayoutAlgorithm layoutAlgorithm;

  /// Creates an instance of [AndroidWebViewConfiguration] with default values.
  const AndroidWebViewConfiguration({
    this.enableSlowWholeDocumentDraw = true,
    this.useWideViewPort = true,
    this.loadWithOverviewMode = true,
    this.setSupportZoom = true,
    this.builtInZoomControls = true,
    this.displayZoomControls = false,
    this.layoutAlgorithm = AndroidWebViewLayoutAlgorithm.normal,
  });

  Map<String, dynamic> toMap() {
    return {
      'enable_slow_whole_document_draw': enableSlowWholeDocumentDraw,
      'use_wide_view_port': useWideViewPort,
      'load_with_overview_mode': loadWithOverviewMode,
      'set_support_zoom': setSupportZoom,
      'built_in_zoom_controls': builtInZoomControls,
      'display_zoom_controls': displayZoomControls,
      'layout_algorithm': layoutAlgorithm.name,
    };
  }
}

// Android WebView Layout Algorithms
enum AndroidWebViewLayoutAlgorithm {
  normal('NORMAL'),
  textAutoSizing('"TEXT_AUTOSIZING"');

  final String name;
  const AndroidWebViewLayoutAlgorithm(this.name);
}
