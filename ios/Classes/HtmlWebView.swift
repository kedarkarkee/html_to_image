import UIKit
import WebKit

class HtmlWebView: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
    private var webView: WKWebView!
    private var urlObservation: NSKeyValueObservation?
    private var content: String
    private var width: Double?
    private var height: Double?
    private var margins: [Int]
    private var useDeviceScaleFactor: Bool
    private var delay: Int
    private var dimensionScript: String?
    private var webViewConfiguration: [String: Any]
    private var currentScale: CGFloat = 1.0
    private var completion: (Data?) -> Void

    init(
        content: String,
        width: Double?,
        height: Double?,
        margins: [Int],
        useDeviceScaleFactor: Bool,
        delay: Int,
        dimensionScript: String?,
        webViewConfiguration: [String: Any],
        completion: @escaping (Data?) -> Void
    ) {
        self.content = content
        self.width = width
        self.height = height
        self.margins = margins
        self.useDeviceScaleFactor = useDeviceScaleFactor
        self.delay = delay
        self.dimensionScript = dimensionScript
        self.webViewConfiguration = webViewConfiguration
        self.completion = completion
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.currentScale = scrollView.zoomScale
    }

    private func getConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let prefs = WKPreferences()
        prefs.javaScriptEnabled =
            webViewConfiguration["javascript_enabled"] as? Bool ?? true
        prefs.javaScriptCanOpenWindowsAutomatically =
            webViewConfiguration["javascript_can_open_windows_automatically"]
            as? Bool ?? false
        config.preferences = prefs
        return config
    }

    func process() {
        self.webView = WKWebView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.size.width,
                height: UIScreen.main.bounds.size.height
            ),
            configuration: getConfig()
        )
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        self.webView.isHidden = true
        self.webView.tag = 100
        self.webView.loadHTMLString(
            self.content,
            baseURL: Bundle.main.resourceURL
        )
        urlObservation = webView.observe(
            \.isLoading,
            changeHandler: { (webView, change) in
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + .milliseconds(self.delay)
                ) {
                    if #available(iOS 11.0, *) {
                        self.webView.scrollView
                            .contentInsetAdjustmentBehavior =
                            UIScrollView.ContentInsetAdjustmentBehavior
                            .never
                        let configuration = WKSnapshotConfiguration()
                        self.getContentDimensions(
                            width: self.width,
                            height: self.height,
                            dimensionScript: self.dimensionScript,
                        ) {
                            (size) in
                            let scaledWidth = size.width * self.currentScale
                            let scaledHeight = size.height * self.currentScale
                            configuration.rect = CGRect(
                                origin: .zero,
                                size: CGSizeMake(scaledWidth, scaledHeight)
                            )
                            NSLog("Scaled Width is %f", scaledWidth)
                            NSLog("Size Width is %f", size.width)
                            NSLog("Current Scale is %f", self.currentScale)

                            let targetWidth =
                                self.useDeviceScaleFactor
                                ? size.width : size.width / UIScreen.main.scale

                            configuration.snapshotWidth =
                                targetWidth as NSNumber
                            self.webView
                                .snapshotView(afterScreenUpdates: true)
                            self.webView
                                .takeSnapshot(with: configuration) {
                                    (originalImage, error) in
                                    guard let image = originalImage else {
                                        self.completion(Data())
                                        self.dispose()
                                        return
                                    }

                                    // Apply margins if any are non-zero
                                    let finalImage: UIImage
                                    let marginLeft = self.margins[0]
                                    let marginTop = self.margins[1]
                                    let marginRight = self.margins[2]
                                    let marginBottom = self.margins[3]
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
                                        self.completion(Data())
                                        self.dispose()
                                        return
                                    }
                                    self.completion(data)

                                    self.dispose()

                                }
                        }
                    } else {
                        self.completion(Data())
                        self.dispose()
                    }

                }
            }
        )
    }

    func getContentDimensions(
        width: Double?,
        height: Double?,
        dimensionScript: String?,
        completion: @escaping (CGSize) -> Void
    ) {
        let frameSize = CGSizeMake(
            width ?? self.webView.frame.width,
            height ?? self.webView.frame.height
        )
        if dimensionScript == nil {
            completion(frameSize)
            return
        }
        self.webView.evaluateJavaScript(dimensionScript!) { result, error in
            if let array = result as? [Double], array.count == 2 {
                let contentWidth = array[0]
                let contentHeight = array[1]
                completion(CGSizeMake(contentWidth, contentHeight))
            } else {
                completion(frameSize)
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
