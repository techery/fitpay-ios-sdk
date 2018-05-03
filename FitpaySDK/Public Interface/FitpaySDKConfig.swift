import Foundation

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
    public static var authURL = "https://auth.fit-pay.com/oauth/authorize"
    
    //rederict url
    
    //sse
    
    //app2app
    
    
    /// Setup FitpaySDK
    ///
    /// - Parameter clientId: clientId from Fitpay
    public static func config(clientId: String) {
        self.clientId = clientId
        
        log.addOutput(output: ConsoleOutput())        
    }
    

}

// MARK: - WebConfig

extension FitpaySDKConfig {
    
    public class WebConfig: NSObject {
        
    }
    
}

// MARK: - DeviceConfig

extension FitpaySDKConfig {
    
    public class DeviceConfig: NSObject {
        
        //apdu transport mode
        
        public var maxPacketSize = 20
        
        public var apduSecsTimeout: Double = 5
        
    }
    
}

// MARK: - HttpConfig

extension FitpaySDKConfig {
    
    public class HttpConfig: NSObject {
        

    }
    
}

