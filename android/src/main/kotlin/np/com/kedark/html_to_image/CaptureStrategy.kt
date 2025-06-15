package np.com.kedark.html_to_image

import android.util.DisplayMetrics

class CaptureStrategy(
    val width: Int?,
    val height: Int?,
    val script: String?
) {
    companion object {
        fun parseFromMap(map: Map<*, *>, displayMetrics: DisplayMetrics): CaptureStrategy {
            val width =
                (map["width"] as? Int?)?.let { it * displayMetrics.density }
            val height = (map["height"] as? Int?)?.let { it * displayMetrics.density }
            val script = map["script"] as? String
            return CaptureStrategy(width?.toInt(), height?.toInt(), script)
        }
    }
}