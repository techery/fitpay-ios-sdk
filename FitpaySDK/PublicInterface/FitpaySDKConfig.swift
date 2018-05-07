import Foundation

/// Main Configuration Object
public class FitpaySDKConfig: NSObject {
    
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
    public static let sdkVersion = Bundle(for: FitpaySDKConfig.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
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
            FitpaySDKConfig.clientId = clientId
        }
        
        if let baseAPIUrl = envDict["SDK_API_BASE_URL"], !baseAPIUrl.isEmpty {
            FitpaySDKConfig.apiURL = baseAPIUrl
        }
        
        if let baseAuthUrl = envDict["SDK_AUTHORIZE_BASE_URL"], !baseAuthUrl.isEmpty {
            FitpaySDKConfig.authURL = baseAuthUrl
        }
        
    }
    
}

// MARK: - WebConfig

extension FitpaySDKConfig {
    
    /// Configuration options related to the Web specifically
    public class Web: NSObject {

        /// Shows autofill options on the add card page when enabled
        public static var demoMode = false

        /// Overrides the default CSS
        public static var cssURL: String?

        /// Turn on when you are ready to implement card scanning methods
        public static var supportCardScanner = false
        
    }
    
}

// MARK: - PaymentDeviceConfig

extension FitpaySDKConfig {
    
    /// Configuration options related to the Payment Device specifically
    public class PaymentDevice: NSObject {
        
        /// Commit timeout in seconds
        public static var commitProcessingTimeout: Double = 30

        //apdu transport mode
        
        //public var maxPacketSize = 20
        
        //public var apduSecsTimeout: Double = 5
        
    }
    
}
