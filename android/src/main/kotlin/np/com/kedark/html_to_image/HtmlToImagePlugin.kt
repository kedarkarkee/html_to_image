package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient

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
        val tag = "html_to_image"
        if (method == "convertToImage") {
            Log.w(tag, "\n activity $activity")
            webView = WebView(this.context)
            val dwidth = this.activity.window.windowManager.defaultDisplay.width
            val dheight = this.activity.window.windowManager.defaultDisplay.height
            webView.layout(0, 0, dwidth, dheight)
            webView.loadDataWithBaseURL(null, content, "text/HTML", "UTF-8", null)
            webView.setInitialScale(1)
            webView.settings.javaScriptEnabled = true
            webView.settings.useWideViewPort = true
            webView.settings.javaScriptCanOpenWindowsAutomatically = true
            webView.settings.loadWithOverviewMode = true
            WebView.enableSlowWholeDocumentDraw()
            webView.webViewClient = object : WebViewClient() {
                override fun onPageFinished(view: WebView, url: String) {
                    super.onPageFinished(view, url)

                    val scope = CoroutineScope(Dispatchers.IO)
                    scope.launch {
                        // Perform WebView-to-image conversion on a background thread
                        val duration =
                            (dheight / 1000).toInt() * 200 /// delay 200 ms for every height 2000

                        Handler(Looper.getMainLooper()).postDelayed({
                            Log.w(tag, "\nOS Version: ${android.os.Build.VERSION.SDK_INT}")

                            webView.evaluateJavascript("(function() { return [document.body.offsetWidth, document.body.offsetHeight]; })();") {
                                val xy = JSONArray(it)
                                val offsetWidth = xy[0].toString()
                                var offsetHeight = xy[1].toString()
                                if (offsetHeight.toInt() < 1000) {
                                    offsetHeight = (xy[1].toString().toInt() + 20).toString()
                                }
                                Log.w(tag, "\n width height $it ${it is String} ${xy[0]} ${xy[1]}")
                                val data = webView.toBitmap(
                                    offsetWidth.toDouble(),
                                    offsetHeight.toDouble()
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

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        print("onAttachedToActivity")
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
        val width = (offsetWidth * this.scale).absoluteValue.toInt()
        val height = (offsetHeight * this.scale).absoluteValue.toInt()
        print("\nwidth $width")
        print("\nheight $height")
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

