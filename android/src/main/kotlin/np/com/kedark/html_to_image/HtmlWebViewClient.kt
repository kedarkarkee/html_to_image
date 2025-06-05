package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import android.webkit.WebView.VisualStateCallback
import android.webkit.WebViewClient
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray


class HtmlWebViewClient(
    private val width: Int?,
    private val height: Int?,
    val content: String,
    private val delay: Int,
    private val margins: List<Int>,
    private val dimensionScript: String?,
    private val result: MethodChannel.Result
) : WebViewClient() {
    var currentScale: Float = 1.0f

    override fun onScaleChanged(view: WebView?, oldScale: Float, newScale: Float) {
        super.onScaleChanged(view, oldScale, newScale)
        this.currentScale = newScale
    }

    @SuppressLint("WebViewApiAvailability")
    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        if (view !is HtmlWebView) {
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            view.postVisualStateCallback(1L, object : VisualStateCallback() {
                override fun onComplete(id: Long) {
                    if (id != 1L) return
                    processWebView(view)
                }
            })
        } else {
            processWebView(view)
        }
    }

    private fun processWebView(view: HtmlWebView) {
        val scope = CoroutineScope(Dispatchers.IO)
        scope.launch {
            // Perform WebView-to-image conversion on a background thread
            Handler(Looper.getMainLooper()).postDelayed({
                getContentDimensions(
                    view
                ) { contentWidth, contentHeight ->
                    val bytes =
                        view.captureImage(
                            contentWidth.toDouble(),
                            contentHeight.toDouble(),
                            margins
                        )
                    if (bytes != null) {
                        result.success(bytes)
                    } else {
                        result.error(
                            "CONVERSION_FAILED", "Failed to convert HTML to image", null
                        )
                    }
                }
            }, delay.toLong())
        }
    }

    private fun getContentDimensions(
        webView: HtmlWebView,
        callback: (Number, Number) -> Unit
    ) {
        if (dimensionScript == null) {
            callback(width ?: webView.widthPixels, height ?: webView.heightPixels)
            return
        }
        webView.evaluateJavascript(
            dimensionScript
        ) {
            val xy = JSONArray(it)
            val contentWidth = (xy[0] as? Number)?.toDouble() ?: 0.0
            val contentHeight = (xy[1] as? Number)?.toDouble() ?: 0.0
            callback(contentWidth, contentHeight)
        }
    }
}