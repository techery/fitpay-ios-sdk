import Foundation
import WebKit

@objc open class FitpayWeb: NSObject {
    
    public static let shared = FitpayWeb()

    weak open var rtmDelegate: WvRTMDelegate? {
        didSet {
            self.wvConfig.rtmDelegate = rtmDelegate
        }
    }
    
    private var wkWebView: WKWebView!
    private var wvConfig: WvConfig!
    
    /// Setup a WKWebview for use
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
        
        wkWebView!.navigationDelegate = self // need docs on overriding
        
        return wkWebView!
    }
    
    /// Loads the main page on Fitpay based on user variables
    @objc open func load() {
        wkWebView.load(wvConfig!.wvRequest())
        wvConfig.webViewPageLoaded()
    }
    
    @objc open func webViewPageLoaded() {
         wvConfig.webViewPageLoaded()
    }
    
}


extension FitpayWeb: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewPageLoaded()
    }
    
}
