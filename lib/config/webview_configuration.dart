class WebViewConfiguration {
  final bool javaScriptEnabled;
  final bool javaScriptCanOpenWindowsAutomatically;
  final AndroidWebViewConfiguration androidWebViewConfiguration;

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

class AndroidWebViewConfiguration {
  final bool enableSlowWholeDocumentDraw;
  final bool useWideViewPort;
  final bool loadWithOverviewMode;
  final bool setSupportZoom;
  final bool builtInZoomControls;
  final bool displayZoomControls;
  final AndroidWebViewLayoutAlgorithm layoutAlgorithm;

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

enum AndroidWebViewLayoutAlgorithm {
  normal('NORMAL'),
  textAutoSizing('"TEXT_AUTOSIZING"');

  final String name;
  const AndroidWebViewLayoutAlgorithm(this.name);
}
