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
class HtmlWebView(
    context: Context,
    private val client: HtmlWebViewClient,
    private val configuration: Map<*, *>,
    private val useDeviceScaleFactor: Boolean
) :
    WebView(context) {

    init {
        this.webViewClient = client
        this.layout(0, 0, widthPixels, heightPixels)
        this.loadDataWithBaseURL(null, client.content, "text/HTML", "UTF-8", null)
        configureWebViewSettings()
    }

    val widthPixels: Int
        get() = this.resources.displayMetrics.widthPixels

    val heightPixels: Int
        get() = this.resources.displayMetrics.heightPixels

    @SuppressLint("SetJavaScriptEnabled")
    private fun configureWebViewSettings() {
        this.settings.apply {
            javaScriptEnabled = configuration["javascript_enabled"] as? Boolean ?: true
            javaScriptCanOpenWindowsAutomatically =
                configuration["javascript_can_open_windows_automatically"] as? Boolean ?: false

            val androidWebViewSettings =
                configuration["android_web_view_configuration"] as Map<*, *>
            useWideViewPort = androidWebViewSettings["use_wide_view_port"] as? Boolean ?: true
            loadWithOverviewMode =
                androidWebViewSettings["load_with_overview_mode"] as? Boolean ?: true
            setSupportZoom(androidWebViewSettings["set_support_zoom"] as? Boolean ?: true)
            builtInZoomControls =
                androidWebViewSettings["built_in_zoom_controls"] as? Boolean ?: true
            displayZoomControls =
                androidWebViewSettings["display_zoom_controls"] as? Boolean ?: false
            layoutAlgorithm = when (androidWebViewSettings["layout_algorithm"] as? String) {
                "NORMAL" -> WebSettings.LayoutAlgorithm.NORMAL
                "TEXT_AUTOSIZING" -> WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING
                else -> WebSettings.LayoutAlgorithm.NORMAL
            }
            if (androidWebViewSettings["enable_slow_whole_document_draw"] as? Boolean == true) {
                enableSlowWholeDocumentDraw()
            }
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
            val currentScale = client.currentScale
            val densityFactor = if (useDeviceScaleFactor) resources.displayMetrics.density else 1.0f

            val width = ceil(offsetWidth * currentScale * densityFactor).absoluteValue.toInt()
            val height = ceil(offsetHeight * currentScale * densityFactor).absoluteValue.toInt()
            this.measure(
                MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
                MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
            )
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            if (useDeviceScaleFactor) {
                canvas.scale(densityFactor, densityFactor)
            }

            this.draw(canvas)
            return bitmap
        }
        return null
    }

}