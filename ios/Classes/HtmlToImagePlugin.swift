import Flutter
import UIKit
import WebKit

public class HtmlToImagePlugin: NSObject, FlutterPlugin {
    var webView : WKWebView!
    var urlObservation: NSKeyValueObservation?
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "html_to_image", binaryMessenger: registrar.messenger())
        let instance = HtmlToImagePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        if (arguments == nil) {
            return
        }
        let content = arguments!["content"] as? String
        let delay = arguments!["delay"] as? Double ?? 200.0
        let width = arguments!["width"] as? Double ?? UIScreen.main.bounds.size.width
        switch call.method {
        case "convertToImage":
            self.webView = WKWebView(frame: CGRect(x: 0,y: 0 , width: width, height: UIScreen.main.bounds.size.height))
            self.webView.isHidden = true
            self.webView.tag = 100
            self.webView.loadHTMLString(content!, baseURL: Bundle.main.resourceURL)
            var bytes = FlutterStandardTypedData.init(bytes: Data() )
            urlObservation = webView.observe(\.isLoading, changeHandler: { (webView, change) in
                DispatchQueue.main.asyncAfter(deadline: .now() + (delay/1000) ) {
                    if #available(iOS 11.0, *) {
                        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
                        let configuration = WKSnapshotConfiguration()
                        var size = self.webView.scrollView.contentSize
                        size.height = size.height + 50
                        configuration.rect = CGRect(origin: .zero, size: size)
                        self.webView.snapshotView(afterScreenUpdates: true)
                        self.webView.takeSnapshot(with: configuration) { (image, error) in
                            guard let data = image!.jpegData(compressionQuality: 1) else {
                                result( bytes )
                                self.dispose()
                                return
                            }
                            bytes = FlutterStandardTypedData.init(bytes: data)
                            result(bytes)
                            
                            self.dispose()
                            
                        }
                    } else {
                        result( bytes )
                        self.dispose()
                    }
                    
                }
            })
            
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    func dispose() {
        if let viewWithTag = self.webView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            if #available(iOS 9.0, *) {
                WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    }
                }
            }
        }
        self.webView = nil
    }
}
