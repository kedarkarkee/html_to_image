package np.com.kedark.html_to_image

import android.util.DisplayMetrics

class LayoutStrategy(
    val width: Int,
    val height: Int
) {
    companion object {
        fun parseFromMap(map: Map<*, *>, displayMetrics: DisplayMetrics): LayoutStrategy {
            val width =
                map["width"] as? Int? ?: displayMetrics.widthPixels
            val height = map["height"] as? Int? ?: displayMetrics.heightPixels

            return LayoutStrategy(
                (width * displayMetrics.density).toInt(),
                (height * displayMetrics.density).toInt()
            )
        }
    }
}