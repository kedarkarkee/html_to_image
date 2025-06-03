package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.webkit.WebSettings
import android.webkit.WebView
import kotlin.math.absoluteValue
import kotlin.math.ceil

@SuppressLint("ViewConstructor")
class HtmlWebView(context: Context, private val client: HtmlWebViewClient? = null) :
    WebView(context) {

    init {
        if (client != null) {
            this.webViewClient = client
            this.layout(0, 0, widthPixels, heightPixels)
            this.loadDataWithBaseURL(null, client.content, "text/HTML", "UTF-8", null)
            configureWebViewSettings()
            enableSlowWholeDocumentDraw()
        }
    }

    val widthPixels: Int
        get() = this.resources.displayMetrics.widthPixels

    val heightPixels: Int
        get() = this.resources.displayMetrics.heightPixels

    @SuppressLint("SetJavaScriptEnabled")
    private fun configureWebViewSettings() {
        this.settings.apply {
            javaScriptEnabled = true
            useWideViewPort = true
            javaScriptCanOpenWindowsAutomatically = true
            loadWithOverviewMode = true
            setSupportZoom(true)
            builtInZoomControls = true
            displayZoomControls = false
            layoutAlgorithm = WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING
        }
    }

    fun captureImage(
        width: Double,
        height: Double,
        margins: List<Int>
    ): ByteArray? {
        // Creating the bitmap without margins
        val originalBitmap = toBitmap(
            width, height
        )
        if (originalBitmap == null) {
            return null
        }

        // Apply margins to the bitmap if any margin is non-zero
        val finalBitmap =
            if (margins.any { it > 0 }) {
                originalBitmap.addMargins(
                    margins[0], margins[1], margins[2], margins[3]
                )
            } else {
                originalBitmap
            }
        val bytes = finalBitmap.toByteArray()

        // Recycle bitmaps to free memory if they're different
        if (finalBitmap !== originalBitmap) {
            originalBitmap.recycle()
        }
        return bytes
    }

    private fun toBitmap(offsetWidth: Double, offsetHeight: Double): Bitmap? {
        if (offsetHeight > 0 && offsetWidth > 0) {
            val currentScale = client?.currentScale ?: 1.0f

            val width = ceil(offsetWidth * currentScale).absoluteValue.toInt()
            val height = ceil(offsetHeight * currentScale).absoluteValue.toInt()
            this.measure(
                MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
                MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
            )
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            this.draw(canvas)
            return bitmap
        }
        return null
    }

}