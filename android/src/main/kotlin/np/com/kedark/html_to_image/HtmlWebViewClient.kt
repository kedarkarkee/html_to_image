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


class HtmlWebViewClient(
    val content: String,
    private val delay: Int,
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
                view.getContentDimensions { contentWidth, contentHeight ->
                    val bytes =
                        view.captureImage(
                            contentWidth,
                            contentHeight
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
}