package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.webkit.WebSettings
import android.webkit.WebView
import org.json.JSONArray
import kotlin.math.roundToInt

@SuppressLint("ViewConstructor")
class HtmlWebView(
    context: Context,
    private val client: HtmlWebViewClient,
    private val margins: List<Int>,
    private val layoutStrategy: LayoutStrategy,
    private val captureStrategy: CaptureStrategy,
    private val configuration: Map<*, *>,
    private val useDeviceScaleFactor: Boolean
) :
    WebView(context) {

    init {
        configureWebViewSettings()
        this.webViewClient = client
        this.loadDataWithBaseURL(null, client.content, "text/HTML", "UTF-8", null)
    }

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

    fun getContentDimensions(
        callback: (Int, Int) -> Unit
    ) {
        if (captureStrategy.script == null) {
            callback(
                captureStrategy.width ?: measuredWidth,
                captureStrategy.height ?: measuredHeight
            )
            return
        }
        this.evaluateJavascript(
            captureStrategy.script
        ) {
            val xy = JSONArray(it)
            var contentWidth = (xy[0] as? Number)?.toInt() ?: 0
            var contentHeight = (xy[1] as? Number)?.toInt() ?: 0
            contentWidth = if (contentWidth == 0) {
                measuredWidth
            } else {
                (contentWidth * this.resources.displayMetrics.density).toInt()
            }
            contentHeight = if (contentHeight == 0) {
                measuredHeight
            } else {
                (contentHeight * this.resources.displayMetrics.density).toInt()
            }
            callback(contentWidth, contentHeight)
        }
    }

    fun captureImage(
        width: Int,
        height: Int
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
            finalBitmap.recycle()
        } else {
            finalBitmap.recycle()
        }
        return bytes
    }

    fun measureAndLayout() {
        this.measure(
            MeasureSpec.makeMeasureSpec(layoutStrategy.width, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(layoutStrategy.height, MeasureSpec.EXACTLY)
        )
        this.layout(0, 0, measuredWidth, measuredHeight)
    }

    private fun toBitmap(offsetWidth: Int, offsetHeight: Int): Bitmap? {
        val currentScale = client.currentScale
        val density = this.resources.displayMetrics.density
        val targetWidth =
            if (useDeviceScaleFactor) offsetWidth else (offsetWidth / density).roundToInt()
        val targetHeight =
            if (useDeviceScaleFactor) offsetHeight else (offsetHeight / density).roundToInt()
        this.measure(
            if (offsetWidth < 0) MeasureSpec.makeMeasureSpec(
                0,
                MeasureSpec.UNSPECIFIED
            ) else MeasureSpec.makeMeasureSpec(targetWidth, MeasureSpec.EXACTLY),
            if (offsetHeight < 0) MeasureSpec.makeMeasureSpec(
                0,
                MeasureSpec.UNSPECIFIED
            ) else MeasureSpec.makeMeasureSpec(targetHeight, MeasureSpec.EXACTLY)
        )
        val finalMeasuredWidth =
            if (useDeviceScaleFactor) measuredWidth else (measuredWidth / density).toInt()
        val finalTargetWidth = if (offsetWidth < 0) finalMeasuredWidth else targetWidth

        val finalMeasuredHeight =
            if (useDeviceScaleFactor) measuredHeight else (measuredHeight / density).toInt()
        val finalTargetHeight = if (offsetHeight < 0) finalMeasuredHeight else targetHeight

        if (finalTargetWidth <= 0 || finalTargetHeight <= 0) {
            return null
        }
        this.layout(0, 0, finalTargetWidth, finalTargetHeight)
        val bitmap = Bitmap.createBitmap(
            finalTargetWidth,
            finalTargetHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        canvas.scale(1 / currentScale, 1 / currentScale)
        if (useDeviceScaleFactor) {
            canvas.scale(density, density)
        }
        this.draw(canvas)
        return bitmap

    }

}
