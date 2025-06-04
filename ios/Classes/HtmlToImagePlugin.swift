import Flutter
import UIKit
import WebKit

public class HtmlToImagePlugin: NSObject, FlutterPlugin {
    var webView: WKWebView!
    var urlObservation: NSKeyValueObservation?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "html_to_image",
            binaryMessenger: registrar.messenger()
        )
        let instance = HtmlToImagePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let arguments = call.arguments as? [String: Any]
        if arguments == nil {
            return
        }
        let content = arguments!["content"] as? String
        let delay = arguments!["delay"] as? Int ?? 200
        let width = arguments!["width"] as? Double
        let height = arguments!["height"] as? Double

        let margins = arguments!["margins"] as? [Int]

        let dimensionScript = arguments!["dimension_script"] as? String

        switch call.method {
        case "convertToImage":
            let htmlWebView = HtmlWebView(
                content: content!,
                width: width,
                height: height,
                margins: margins!,
                delay: delay,
                dimensionScript: dimensionScript,
                completion: { imageData in
                    if let imageData = imageData {
                        let bytes = FlutterStandardTypedData.init(
                            bytes: imageData
                        )
                        result(bytes)
                    } else {
                        result(
                            FlutterError(
                                code: "CONVERSION_FAILED",
                                message: "Failed to convert HTML to image",
                                details: nil
                            )
                        )
                    }
                }
            )
            htmlWebView.process()
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }

}
