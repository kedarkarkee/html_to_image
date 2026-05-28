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
        let layoutStrategy = LayoutStrategy.parseFromMap(
            (arguments!["layout_strategy"] as? [String: Any])!
        )
        let captureStrategy = CaptureStrategy.parseFromMap(
            (arguments!["capture_strategy"] as? [String: Any])!
        )

        let margins = arguments!["margins"] as? [Int]

        let useDeviceScaleFactor =
            arguments!["use_device_scale_factor"] as? Bool ?? true

        let webViewConfiguration =
            arguments!["web_view_configuration"] as? [String: Any]

        switch call.method {
        case "convertToImage":
            let htmlWebView = HtmlWebView(
                content: content!,
                layoutStrategy: layoutStrategy,
                captureStrategy: captureStrategy,
                margins: margins!,
                useDeviceScaleFactor: useDeviceScaleFactor,
                delay: delay,
                webViewConfiguration: webViewConfiguration!,
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
