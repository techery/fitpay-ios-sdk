import Foundation

/// Main Configuration Object
/// Set variables before instantiating other primary Fitpay objects
public class FitpayConfig: NSObject {
    
    /// Implicit allows you to get a single user token
    public static var clientId: String!
    
    /// Used for web calls
    public static var webURL = "https://webapp.fit-pay.com"
    
    /// Used for redirects
    public static var redirectURL = "https://webapp.fit-pay.com"
    
    /// Used for API calls
    public static var apiURL = "https://api.fit-pay.com"
    
    /// Used during login
    public static var authURL = "https://auth.fit-pay.com"
    
    /// Turn on when you are ready to implement App 2 App stepup methods
    /// Only recommended for iOS 10+
    public static var supportApp2App = false
    
    /// Logs will be sent for every level equal or above what is set
    public static var minLogLevel: LogLevel = LogLevel.info
    
    /// SDK Version using semantic versioning MAJOR.MINOR.PATCH
    public static let sdkVersion = Bundle(for: FitpayConfig.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    //MARK: - Functions
    
    /// Setup FitpaySDK
    ///
    /// Call this method in the AppDelegate `didFinishLaunchingWithOptions:`
    /// before doing anything else with the FItpaySDK
    ///
    /// - Parameter clientId: clientId from Fitpay
    public static func config(clientId: String) {
        self.clientId = clientId
        
        loadEnvironmentVariables()
        log.addOutput(output: ConsoleOutput())
    }
    
    // MARK: - Private
    
    private static func loadEnvironmentVariables() {
        let envDict = ProcessInfo.processInfo.environment
        
        if let clientId = envDict["SDK_CLIENT_ID"], !clientId.isEmpty {
            FitpayConfig.clientId = clientId
        }
        
        if let baseAPIUrl = envDict["SDK_API_BASE_URL"], !baseAPIUrl.isEmpty {
            FitpayConfig.apiURL = baseAPIUrl
        }
        
        if let baseAuthUrl = envDict["SDK_AUTHORIZE_BASE_URL"], !baseAuthUrl.isEmpty {
            FitpayConfig.authURL = baseAuthUrl
        }
        
    }
    
}

// MARK: - WebConfig

extension FitpayConfig {
    
    /// Configuration options related to the Web specifically
    public class Web: NSObject {

        /// Shows autofill options on the add card page when enabled
        /// Turning on in production does nothing
        public static var demoMode = false
        
        /// Changes autofill options to include a default and auto-verify version of one card type
        /// demoMode must be true and not in production for this to work
        public static var demoCardGroup: String?

        /// Overrides the default CSS
        public static var cssURL: String?

        /// Turn on when you are ready to implement card scanning methods
        public static var supportCardScanner = false
        
    }
    
}
