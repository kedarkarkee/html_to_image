package np.com.kedark.html_to_image

import android.util.DisplayMetrics
import kotlin.math.roundToInt

class LayoutStrategy(
    val width: Int,
    val height: Int
) {
    companion object {
        fun parseFromMap(map: Map<*, *>, displayMetrics: DisplayMetrics): LayoutStrategy {
            val mm = map["mm"] as? Boolean
                ?: false
            val width =
                (map["width"] as? Int?)?.let {
                    if (mm) ((it / 25.4) * 72 * displayMetrics.density).roundToInt() else it
                } ?: displayMetrics.widthPixels
            val height = (map["height"] as? Int?)?.let {
                if (mm) ((it / 25.4) * 72 * displayMetrics.density).roundToInt() else it
            } ?: displayMetrics.heightPixels

            return LayoutStrategy(width, height)
        }
    }
}