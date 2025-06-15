import UIKit
import WebKit

class HtmlWebView: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
    private var webView: WKWebView!
    private var urlObservation: NSKeyValueObservation?
    private var content: String
    private var layoutStrategy: LayoutStrategy
    private var captureStrategy: CaptureStrategy
    private var margins: [Int]
    private var useDeviceScaleFactor: Bool
    private var delay: Int
    private var webViewConfiguration: [String: Any]
    private var currentScale: CGFloat = 1.0
    private var completion: (Data?) -> Void

    init(
        content: String,
        layoutStrategy: LayoutStrategy,
        captureStrategy: CaptureStrategy,
        margins: [Int],
        useDeviceScaleFactor: Bool,
        delay: Int,
        webViewConfiguration: [String: Any],
        completion: @escaping (Data?) -> Void
    ) {
        self.content = content
        self.layoutStrategy = layoutStrategy
        self.captureStrategy = captureStrategy
        self.margins = margins
        self.useDeviceScaleFactor = useDeviceScaleFactor
        self.delay = delay
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
                width: layoutStrategy.width,
                height: layoutStrategy.height
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
                        self.getContentDimensions {
                            (size) in
                            let captureWidth =
                                size.width < 0
                                ? self.webView.scrollView.contentSize.width
                                : size.width
                            let captureHeight =
                                size.height < 0
                                ? self.webView.scrollView.contentSize.height
                                : size.height

                            let scaledWidth = captureWidth * self.currentScale
                            let scaledHeight = captureHeight * self.currentScale

                            let targetWidth =
                                self.useDeviceScaleFactor
                                ? captureWidth
                                : captureWidth / UIScreen.main.scale

                            let configuration = WKSnapshotConfiguration()
                            configuration.rect = CGRect(
                                origin: .zero,
                                size: CGSizeMake(scaledWidth, scaledHeight)
                            )
                            configuration.snapshotWidth =
                                targetWidth as NSNumber
                            self.captureImage(config: configuration)
                        }
                    } else {
                        self.completion(Data())
                        self.dispose()
                    }

                }
            }
        )
    }

    private func captureImage(config: WKSnapshotConfiguration) {
        self.webView
            .snapshotView(afterScreenUpdates: true)
        self.webView.takeSnapshot(with: config) {
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
            guard let data = finalImage.pngData() else {
                self.completion(Data())
                self.dispose()
                return
            }
            self.completion(data)
            self.dispose()
        }
    }

    func getContentDimensions(
        completion: @escaping (CGSize) -> Void
    ) {
        let frameSize = CGSizeMake(
            CGFloat(
                self.captureStrategy.width ?? Int(self.webView.frame.width)
            ),
            CGFloat(
                self.captureStrategy.height ?? Int(self.webView.frame.height)
            )
        )
        if self.captureStrategy.script == nil {
            completion(frameSize)
            return
        }
        self.webView.evaluateJavaScript(self.captureStrategy.script!) {
            result,
            error in
            if let array = result as? [Double], array.count == 2 {
                var contentWidth = array[0]
                var contentHeight = array[1]
                if contentWidth == 0 {
                    contentWidth = frameSize.width
                }
                if contentHeight == 0 {
                    contentHeight = frameSize.height
                }
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
