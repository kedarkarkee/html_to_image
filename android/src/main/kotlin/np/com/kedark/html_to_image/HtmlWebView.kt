package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.view.View
import android.webkit.WebSettings
import android.webkit.WebView
import kotlin.math.absoluteValue

class HtmlWebView(context: Context, val client: HtmlWebViewClient? = null) : WebView(context) {

    init {
        if (client != null) {
            this.webViewClient = client
            this.layout(0, 0, client.width, client.height)
            this.loadDataWithBaseURL(null, client.content, "text/HTML", "UTF-8", null)
            configureWebViewSettings()
            enableSlowWholeDocumentDraw()
        }
    }

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
            // Add extra padding to width to prevent clipping
            val scaledDensity =
                this.resources.displayMetrics.density * (client?.currentScale ?: 1.0f)
            val width = (offsetWidth * scaledDensity).absoluteValue.toInt()
            val height = (offsetHeight * scaledDensity).absoluteValue.toInt()
            this.measure(
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            )
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            this.draw(canvas)
            return bitmap
        }
        return null
    }

}