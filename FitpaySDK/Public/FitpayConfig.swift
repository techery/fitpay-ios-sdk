import Foundation

/// Main Configuration Object
/// Set variables before instantiating other Fitpay objects
@objc public class FitpayConfig: NSObject {
    
    /// Implicit allows you to get a single user token
    @objc public static var clientId: String!
    
    /// Used for web calls
    @objc public static var webURL = "https://webapp.fit-pay.com"
    
    /// Used for redirects
    @objc public static var redirectURL = "https://webapp.fit-pay.com"
    
    /// Used for API calls
    @objc public static var apiURL = "https://api.fit-pay.com"
    
    /// Used during login
    @objc public static var authURL = "https://auth.fit-pay.com"
    
    /// Turn on when you are ready to implement App 2 App stepup methods
    /// Only recommended for iOS 10+
    @objc public static var supportApp2App = false
    
    /// Logs will be sent for every level equal or above what is set
    @objc public static var minLogLevel: LogLevel = LogLevel.info
    
    /// SDK Version using semantic versioning MAJOR.MINOR.PATCH
    @objc public static let sdkVersion = Bundle(for: FitpayConfig.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    //MARK: - Functions
    
    /// Setup FitpaySDK quick method
    /// Uses all of the default variables and sets clientId
    ///
    /// Call configure in the AppDelegate `didFinishLaunchingWithOptions:`
    /// before doing anything else with the FItpaySDK
    ///
    /// - Parameter clientId: clientId from Fitpay
    @objc public static func configure(clientId: String) {
        self.clientId = clientId
        
        loadEnvironmentVariables()
        log.addOutput(output: ConsoleOutput())
        
        log.debug("Fitpay configured successfully")
    }
    
    /// Setup FitpaySDK advanced method
    /// All variables are customizable via json file
    /// Call configure in the AppDelegate `didFinishLaunchingWithOptions:`
    /// before doing anything else with the FItpaySDK
    ///
    /// - Parameter fileName: name without extension or leading path defaults to `fitpayconfig`
    @objc public static func configure(fileName: String = "fitpayconfig") {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else { return }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else { return }
        guard let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) else { return }
        guard let fitpayConfigModel = try? FitpayConfigModel(jsonResult) else { return }
        
        FitpayConfig.clientId = fitpayConfigModel.clientId
        
        if let webURL = fitpayConfigModel.webURL {
            FitpayConfig.webURL = webURL
        }
        if let redirectURL = fitpayConfigModel.redirectURL {
            FitpayConfig.redirectURL = redirectURL
        }
        if let apiURL = fitpayConfigModel.apiURL {
            FitpayConfig.apiURL = apiURL
        }
        if let authURL = fitpayConfigModel.authURL {
            FitpayConfig.authURL = authURL
        }
        
        FitpayConfig.supportApp2App = fitpayConfigModel.supportApp2App
        FitpayConfig.minLogLevel = LogLevel(rawValue: fitpayConfigModel.minLogLevel) ?? LogLevel.info
        FitpayConfig.Web.demoMode = fitpayConfigModel.web.demoMode
        FitpayConfig.Web.demoCardGroup = fitpayConfigModel.web.demoCardGroup
        FitpayConfig.Web.cssURL = fitpayConfigModel.web.cssURL
        FitpayConfig.Web.supportCardScanner = fitpayConfigModel.web.supportCardScanner
        
        log.debug("Fitpay configured from file successfully")
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

@objc extension FitpayConfig {
    
    /// Configuration options related to the Web specifically
    @objc public class Web: NSObject {
        
        /// Shows autofill options on the add card page when enabled
        /// Turning on in production does nothing
        @objc public static var demoMode = false
        
        /// Changes autofill options to include a default and auto-verify version of one card type
        /// demoMode must be true and not in production for this to work
        @objc public static var demoCardGroup: String?
        
        /// Overrides the default CSS
        @objc public static var cssURL: String?
        
        /// Turn on when you are ready to implement card scanning methods
        @objc public static var supportCardScanner = false
        
    }
    
}

// MARK: - Structs for json

@objc extension FitpayConfig {
    
    private struct FitpayConfigModel: Serializable {
        var clientId: String
        var webURL: String?
        var redirectURL: String?
        var apiURL: String?
        var authURL: String?
        var supportApp2App: Bool
        var minLogLevel: Int
        var web: FitpayConfigWebModel
    }
    
    private struct FitpayConfigWebModel: Serializable  {
        var demoMode: Bool
        var demoCardGroup: String?
        var cssURL: String?
        var supportCardScanner: Bool
    }
    
}
