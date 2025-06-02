package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Size
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import android.webkit.WebSettings

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONArray
import java.io.ByteArrayOutputStream
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlin.math.absoluteValue

/** HtmlToImagePlugin */
class HtmlToImagePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private lateinit var context: Context
    private lateinit var webView: WebView

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "html_to_image")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method
        val arguments = call.arguments as Map<*, *>
        val content = arguments["content"] as String
        val delay = arguments["delay"] as Int? ?: 200
        val width = arguments["width"] as Int?

        // Get margin parameters with default values
        val margins = (arguments["margins"] as List<*>).map { it as Int? ?: 0 }

        val useExactDimensions = arguments["use_exact_dimensions"] as Boolean? ?: false
        val initialScale = arguments["initial_scale"] as Int? ?: 1

        if (method == "convertToImage") {
            webView = WebView(this.context)
            val displaySize = getDisplaySize()
            val dwidth = width ?: displaySize.width
            val dheight = displaySize.height
            // Use a larger width for layout to prevent clipping
            webView.layout(0, 0, dwidth * 2, dheight)
            webView.loadDataWithBaseURL(null, content, "text/HTML", "UTF-8", null)
            webView.setInitialScale(initialScale)
            configureWebViewSettings(webView)
            WebView.enableSlowWholeDocumentDraw()
            webView.webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView, url: String) {
                    super.onPageFinished(view, url)

                    val scope = CoroutineScope(Dispatchers.IO)
                    scope.launch {
                        // Perform WebView-to-image conversion on a background thread
                        val duration = (dheight / 1000) * delay // Delay for every 1000 px height

                        Handler(Looper.getMainLooper()).postDelayed({
                            getContentDimensions(
                                webView,
                                useExactDimensions
                            ) { contentWidth, contentHeight ->
                                val bytes =
                                    processWebview(webView, contentWidth, contentHeight, margins)
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
            }
        } else {
            return result.notImplemented()
        }
    }

    private fun processWebview(
        webView: WebView,
        width: Double,
        height: Double,
        margins: List<Int>
    ): ByteArray? {
        // Creating the bitmap without margins
        val originalBitmap = webView.toBitmap(
            width, height
        )
        if (originalBitmap == null) {
            return null
        }

        // Apply margins to the bitmap if any margin is non-zero
        val finalBitmap =
            if (margins[0] > 0 || margins[1] > 0 || margins[2] > 0 || margins[3] > 0) {
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

    @SuppressLint("SetJavaScriptEnabled")
    private fun configureWebViewSettings(webView: WebView) {
        webView.settings.apply {
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

    private fun getContentDimensions(
        webView: WebView,
        useExactDimensions: Boolean,
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

    @Suppress("DEPRECATION")
    private fun getDisplaySize(): Size {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val bounds = this.activity.window.windowManager.currentWindowMetrics.bounds
            return Size(bounds.width(), bounds.height())
        }
        val defaultDisplay = this.activity.window.windowManager.defaultDisplay
        return Size(defaultDisplay.width, defaultDisplay.height)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        webView = WebView(activity.applicationContext)
        webView.minimumHeight = 1
        webView.minimumWidth = 1
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}


fun WebView.toBitmap(offsetWidth: Double, offsetHeight: Double): Bitmap? {
    if (offsetHeight > 0 && offsetWidth > 0) {
        // Add extra padding to width to prevent clipping
        val width = ((offsetWidth + 20) * this.scale).absoluteValue.toInt()
        val height = (offsetHeight * this.scale).absoluteValue.toInt()
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

fun Bitmap.toByteArray(): ByteArray {
    ByteArrayOutputStream().apply {
        compress(Bitmap.CompressFormat.PNG, 100, this)
        return toByteArray()
    }
}

fun Bitmap.addMargins(
    leftMargin: Int, topMargin: Int, rightMargin: Int, bottomMargin: Int
): Bitmap {
    // Create a new bitmap with the margins
    val newWidth = width + leftMargin + rightMargin
    val newHeight = height + topMargin + bottomMargin
    val newBitmap = Bitmap.createBitmap(newWidth, newHeight, config)

    // Draw the original bitmap onto the new one with margins
    val canvas = Canvas(newBitmap)
    canvas.drawColor(Color.WHITE) // Fill with white background
    canvas.drawBitmap(this, leftMargin.toFloat(), topMargin.toFloat(), null)

    return newBitmap
}
