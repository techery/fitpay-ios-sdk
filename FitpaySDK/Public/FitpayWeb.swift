import Foundation
import WebKit

/// Main Object for interacting with Fitpay Web app
@objc open class FitpayWeb: NSObject {
    
    /// Use this singleton
    public static let shared = FitpayWeb()

    /// Set the rtmDelegate to receive authorization and other messages from the webview
    /// Needed for capturing a back button press
    weak open var rtmDelegate: RTMDelegate? {
        didSet {
            self.wvConfig.rtmDelegate = rtmDelegate
        }
    }
    
    private var wkWebView: WKWebView!
    private var wvConfig: WvConfig!
    
    /// Setup a Fitpay WKWebview for use
    /// You must use WKWebview returned by this function
    /// This must be called before any other methods
    ///
    /// - Parameters:
    ///   - userEmail: user email - defaults to nil
    ///   - userHasFitpayAccount: user has fitpayAccount - defaults to false
    ///   - paymentDevice: figuring out
    ///   - paymentDeviceConnector: figuring out
    ///   - frame: needed for initializing the wkWebView
    /// - Returns: WKWebview with correct configuration and frame
    @objc open func setupWebView(userEmail: String? = nil, userHasFitpayAccount: Bool = false, paymentDevice: PaymentDevice, paymentDeviceConnector: PaymentDeviceConnectable, frame: CGRect, script: WKUserScript? = nil) -> WKWebView {

        _ = paymentDevice.changeDeviceInterface(paymentDeviceConnector)
        
        let rtmConfig = RtmConfig(userEmail: userEmail, deviceInfo: paymentDeviceConnector.deviceInfo())
        rtmConfig.hasAccount = userHasFitpayAccount
        
        wvConfig = WvConfig(paymentDevice: paymentDevice, rtmConfig: rtmConfig)

        let config = wvConfig!.wvConfig()
        if let script = script {
            config.userContentController.addUserScript(script)
        }
        wkWebView = WKWebView(frame: frame, configuration: config)
        
        wvConfig!.setWebView(wkWebView)
        
        wkWebView!.navigationDelegate = self
        
        return wkWebView!
    }
    
    /// Loads the main page on Fitpay based on user variables
    @objc open func load() {
        wkWebView.load(wvConfig!.wvRequest())
    }
    
    /// Should be called once the webview is loaded
    /// This is called automatically unless you become the navigationDelegate in which case you must set it manually
    /// You can use `WKNavigationDelegate.webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)` for managing page state
    @objc open func webViewPageLoaded() {
         wvConfig.webViewPageLoaded()
    }
    
}


extension FitpayWeb: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewPageLoaded()
    }
    
}
