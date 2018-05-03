import Foundation

internal let log = FitpaySDKLogger.sharedInstance // TODO: do this differently?

/// General Configuration Object
public class FitpaySDKConfig: NSObject {
    
    /// Implicit allows you to get a single user token
    public static var clientId: String!
    
    /// Used for Seb calls
    public static var webURL = "https://webapp.fit-pay.com"
    
    /// Used for redirects?
    public static var redirectURL = "https://webapp.fit-pay.com"
    
    /// Used for API calls
    public static var ApiURL = "https://api.fit-pay.com"
    
    /// Used during login
    public static var authURL = "https://auth.fit-pay.com"
    
    //rederict url
    
    //sse
    
    //app2app
    
    public static let sdkVersion = Bundle(for: FitpaySDKConfig.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

    //MARK: - Functions
    
    /// Setup FitpaySDK
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
            FitpaySDKConfig.ApiURL = baseAPIUrl
        }
        
        if let baseAuthUrl = envDict["SDK_AUTHORIZE_BASE_URL"], !baseAuthUrl.isEmpty {
            FitpaySDKConfig.authURL = baseAuthUrl
        }
        
    }
    

}

// MARK: - WebConfig

extension FitpaySDKConfig {
    
    public class Web: NSObject {
        
    }
    
}

// MARK: - DeviceConfig

extension FitpaySDKConfig {
    
    public class PaymentDevice: NSObject {
        
        /// Timeout in Seconds
        public static var commitProcessingTimeout: Double = 30

        //apdu transport mode
        
        //public var maxPacketSize = 20
        
        //public var apduSecsTimeout: Double = 5
        

    }
    
}

// MARK: - HttpConfig

extension FitpaySDKConfig {
    
    public class Http: NSObject {
        

    }
    
}

