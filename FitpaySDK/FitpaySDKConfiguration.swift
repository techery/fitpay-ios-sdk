import Foundation

internal let log = FitpaySDKLogger.sharedInstance

open class FitpaySDKConfiguration: NSObject {
    open static let defaultConfiguration = FitpaySDKConfiguration()
    
    open var commitProcessingTimeoutSecs: Double = 30.0
    
    open static let sdkVersion = Bundle(for: FitpaySDKConfiguration.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "unk"
    
    // MARK: - Lifecycle
    
    override public init() {
        super.init()
        
        self.setupLogs()
    }
    
    // MARK: - Functions
    
    open func loadEnvironmentVariables() -> Error? {
        let envDict = ProcessInfo.processInfo.environment

        //clientId checks
        guard let clientId = envDict["SDK_CLIENT_ID"], !clientId.isEmpty else {
            return EnvironmentLoadingErrors.clientIdIsEmpty
        }
        
        //baseAPIUrl checks
        guard let baseAPIUrl = envDict["SDK_API_BASE_URL"], !baseAPIUrl.isEmpty else {
            return EnvironmentLoadingErrors.baseApiUrlIsEmpty
        }
        
        //baseAuthBaseUrl checks
        guard let baseAuthBaseUrl = envDict["SDK_AUTHORIZE_BASE_URL"], !baseAuthBaseUrl.isEmpty else {
            return EnvironmentLoadingErrors.authorizeURLIsEmpty
        }
        
        FitpaySDKConfig.authURL = baseAuthBaseUrl
        FitpaySDKConfig.ApiURL = baseAPIUrl
        
        return nil
    }
    
    // MARK: - Internal / Private

    private func setupLogs() {
        log.addOutput(output: ConsoleOutput())
    }
    
}

//MARK: - Nested Objects

extension FitpaySDKConfiguration {
    
    enum EnvironmentLoadingErrors: Error {
        case clientIdIsEmpty
        case clientSecretIsEmpty
        case baseApiUrlIsEmpty
        case authorizeURLIsEmpty
    }
    
}
