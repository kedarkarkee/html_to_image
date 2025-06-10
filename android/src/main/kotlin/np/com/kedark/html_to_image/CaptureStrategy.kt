package np.com.kedark.html_to_image

class CaptureStrategy(
    val width: Int?,
    val height: Int?,
    val script: String?
) {
    companion object {
        fun parseFromMap(map: Map<*, *>): CaptureStrategy {
            val width =
                map["width"] as? Int?
            val height = map["height"] as? Int?
            val script = map["script"] as? String
            return CaptureStrategy(width, height, script)
        }
    }
}