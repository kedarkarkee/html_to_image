package np.com.kedark.html_to_image

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.ByteArrayOutputStream

/** HtmlToImagePlugin */
class HtmlToImagePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var webView: HtmlWebView

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
        val height = arguments["height"] as Int?

        val margins = (arguments["margins"] as List<*>).map { it as Int? ?: 0 }

        val useDeviceScaleFactor = arguments["use_device_scale_factor"] as Boolean? ?: true

        val dimensionScript = arguments["dimension_script"] as String?

        val webViewConfiguration = arguments["web_view_configuration"] as Map<*, *>

        if (method == "convertToImage") {
            webView = HtmlWebView(
                this.context,
                HtmlWebViewClient(
                    width,
                    height,
                    content,
                    delay,
                    margins,
                    dimensionScript,
                    result
                ),
                webViewConfiguration,
                useDeviceScaleFactor
            )
        } else {
            return result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
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
