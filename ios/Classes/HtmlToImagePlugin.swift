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
        let delay = arguments!["delay"] as? Double ?? 200.0
        let width =
        arguments!["width"] as? Double ?? UIScreen.main.bounds.size.width

        // Get margin parameters with default values
        let margins = arguments!["margins"] as? [Int]
        let marginLeft = margins![0] as Int
        let marginTop = margins![1] as Int
        let marginRight = margins![2] as Int
        let marginBottom = margins![3] as Int
        
        let useExactDimensions = arguments!["use_exact_dimensions"] as? Bool ?? false

        switch call.method {
        case "convertToImage":
            self.webView = WKWebView(
                frame: CGRect(
                    x: 0,
                    y: 0,
                    width: width,
                    height: UIScreen.main.bounds.size.height
                )
            )
            self.webView.isHidden = true
            self.webView.tag = 100
            self.webView.loadHTMLString(
                content!,
                baseURL: Bundle.main.resourceURL
            )
            var bytes = FlutterStandardTypedData.init(bytes: Data())
            urlObservation = webView.observe(
                \.isLoading,
                 changeHandler: { (webView, change) in
                     DispatchQueue.main.asyncAfter(
                        deadline: .now() + (delay / 1000)
                     ) {
                         if #available(iOS 11.0, *) {
                             self.webView.scrollView
                                 .contentInsetAdjustmentBehavior =
                             UIScrollView.ContentInsetAdjustmentBehavior
                                 .never
                             let configuration = WKSnapshotConfiguration()
                             self.getContentDimensions(
                                useExactDimensions: useExactDimensions
                             ) {
                                 (size) in
                                 configuration.rect = CGRect(
                                    origin: .zero,
                                    size: size
                                 )
                                 self.webView
                                     .snapshotView(afterScreenUpdates: true)
                                 self.webView
                                     .takeSnapshot(with: configuration) {
                                         (originalImage, error) in
                                         guard let image = originalImage else {
                                             result(bytes)
                                             self.dispose()
                                             return
                                         }

                                         // Apply margins if any are non-zero
                                         let finalImage: UIImage
                                         if marginLeft > 0 || marginTop > 0
                                                || marginRight > 0 || marginBottom > 0
                                         {
                                             finalImage = self.addMargins(
                                                to: image,
                                                left: marginLeft,
                                                top: marginTop,
                                                right: marginRight,
                                                bottom: marginBottom
                                             )
                                         } else {
                                             finalImage = image
                                         }
                                         guard
                                            let data = finalImage.pngData()
                                         else {
                                             result(bytes)
                                             self.dispose()
                                             return
                                         }

                                         bytes = FlutterStandardTypedData.init(
                                            bytes: data
                                         )
                                         result(bytes)

                                         self.dispose()

                                     }
                             }
                         } else {
                             result(bytes)
                             self.dispose()
                         }

                     }
                 }
            )

            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func getContentDimensions(
        useExactDimensions: Bool,
        completion: @escaping (CGSize) -> Void
    ) {
        if(!useExactDimensions){
            completion(self.webView.scrollView.contentSize)
            return
        }
        let js = """
        (function() {
            let maxRight = 0;
            let maxBottom = 0;
            document.body.querySelectorAll('*').forEach(el => {
                const rect = el.getBoundingClientRect();
                maxRight = Math.max(maxRight, rect.right);
                maxBottom = Math.max(maxBottom, rect.bottom);
            });
            return [maxRight, maxBottom];
        })();
        """

        self.webView.evaluateJavaScript(js) { result, error in
            if let array = result as? [Double], array.count == 2 {
                let contentWidth = array[0]
                let contentHeight = array[1]
                completion(CGSizeMake(contentWidth, contentHeight))
            } else {
                completion(self.webView.scrollView.contentSize)
            }
        }
    }

    // Function to add margins to an image
    private func addMargins(
        to image: UIImage,
        left: Int,
        top: Int,
        right: Int,
        bottom: Int
    ) -> UIImage {
        let newWidth = Int(image.size.width) + left + right
        let newHeight = Int(image.size.height) + top + bottom

        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: newWidth, height: newHeight),
            true,
            image.scale
        )
        let context = UIGraphicsGetCurrentContext()!

        // Fill the background with white
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        // Draw the original image with margins
        image.draw(
            in: CGRect(
                x: left,
                y: top,
                width: Int(image.size.width),
                height: Int(image.size.height)
            )
        )

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }

    func dispose() {
        if let viewWithTag = self.webView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            if #available(iOS 9.0, *) {
                WKWebsiteDataStore.default().fetchDataRecords(
                    ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
                ) { records in
                    records.forEach { record in
                        WKWebsiteDataStore.default().removeData(
                            ofTypes: record.dataTypes,
                            for: [record],
                            completionHandler: {}
                        )
                    }
                }
            }
        }
        self.webView = nil
    }
}
