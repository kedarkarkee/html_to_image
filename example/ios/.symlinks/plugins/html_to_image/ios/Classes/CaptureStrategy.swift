class CaptureStrategy {
    let width: Int?
    let height: Int?
    let script: String?

    init(width: Int?, height: Int?, script: String?) {
        self.width = width
        self.height = height
        self.script = script
    }

    static func parseFromMap(_ map: [String: Any]) -> CaptureStrategy {
        let width = map["width"] as? Int
        let height = map["height"] as? Int
        let script = map["script"] as? String
        return CaptureStrategy(width: width, height: height, script: script)
    }
}