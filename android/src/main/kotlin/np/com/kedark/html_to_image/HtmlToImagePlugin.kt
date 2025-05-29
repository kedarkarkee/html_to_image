package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
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
        if (method == "convertToImage") {
            webView = WebView(this.context)
            val displaySize = getDisplaySize()
            val dwidth = width ?: displaySize.width
            val dheight = displaySize.height
            // Use a larger width for layout to prevent clipping
            webView.layout(0, 0, dwidth * 2, dheight)
            webView.loadDataWithBaseURL(null, content, "text/HTML", "UTF-8", null)
            webView.setInitialScale(1)
            webView.settings.javaScriptEnabled = true
            webView.settings.useWideViewPort = true
            webView.settings.javaScriptCanOpenWindowsAutomatically = true
            webView.settings.loadWithOverviewMode = true
            webView.settings.setSupportZoom(true)
            webView.settings.builtInZoomControls = true
            webView.settings.displayZoomControls = false
            webView.settings.layoutAlgorithm = WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING
            WebView.enableSlowWholeDocumentDraw()
            webView.webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView, url: String) {
                    super.onPageFinished(view, url)

                    val scope = CoroutineScope(Dispatchers.IO)
                    scope.launch {
                        // Perform WebView-to-image conversion on a background thread
                        val duration =
                            (dheight / 1000) * delay // Delay for every 1000 px height

                        Handler(Looper.getMainLooper()).postDelayed({

                            webView.evaluateJavascript("""
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
                            """) {
                                val xy = JSONArray(it)
                                val contentWidth = xy[0].toString().toInt()
                                var contentHeight = xy[1].toString().toInt()
                                if (contentHeight < 1000) {
                                    contentHeight += 20
                                }
                                val data = webView.toBitmap(
                                    contentWidth.toDouble(),
                                    contentHeight.toDouble()
                                )
                                if (data != null) {
                                    val bytes = data.toByteArray()
                                    result.success(bytes)
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
