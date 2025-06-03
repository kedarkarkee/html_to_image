package np.com.kedark.html_to_image

import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.plugin.common.MethodChannel

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray


class HtmlWebViewClient(
    val width: Int,
    val height: Int,
    val content: String,
    val delay: Int,
    val margins: List<Int>,
    val useExactDimensions: Boolean,
    private val result: MethodChannel.Result
) : WebViewClient() {
    var currentScale: Float = 1.0f // Initialize with default scale

    override fun onScaleChanged(view: WebView?, oldScale: Float, newScale: Float) {
        super.onScaleChanged(view, oldScale, newScale)
        this.currentScale = newScale
    }

    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        if (view !is HtmlWebView) {
            return
        }

        val scope = CoroutineScope(Dispatchers.IO)
        scope.launch {
            // Perform WebView-to-image conversion on a background thread
            val duration = (height / 1000) * delay // Delay for every 1000 px height

            Handler(Looper.getMainLooper()).postDelayed({
                getContentDimensions(
                    view
                ) { contentWidth, contentHeight ->
                    val bytes =
                        view.captureImage(contentWidth, contentHeight, margins)
                    if (bytes != null) {
                        result.success(bytes)
                    } else {
                        result.error(
                            "CONVERSION_FAILED", "Failed to convert HTML to image", null
                        )
                    }
                }
            }, duration.toLong())
        }
    }

    private fun getContentDimensions(
        webView: WebView,
        callback: (Double, Double) -> Unit
    ) {
        webView.evaluateJavascript(
            if (useExactDimensions) """
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
                            """ else """
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
                            """
        ) {
            val xy = JSONArray(it)
            val contentWidth = (xy[0] as? Number)?.toDouble() ?: 0.0
            val contentHeight = (xy[1] as? Number)?.toDouble() ?: 0.0
            callback(contentWidth, contentHeight)
        }
    }
}