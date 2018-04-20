import ObjectMapper

public enum RtmConfigDafaultMappingKey: String {
    case clientId = "clientId"
    case redirectUri = "redirectUri"
    case userEmail = "userEmail"
    case deviceInfo = "paymentDevice"
    case hasAccount = "account"
    case version = "version"
    case demoMode = "demoMode"
    case customCSSUrl = "themeOverrideCssUrl"
    case demoCardGroup = "demoCardGroup"
    case accessToken = "accessToken"
    case language = "language"
    case baseLanguageUrl = "baseLangUrl"
    case useWebCardScanner = "useWebCardScanner"
}

@objc public protocol RtmConfigProtocol {
    var clientId: String? { get }
    var redirectUri: String? { get }
    var deviceInfo: DeviceInfo? { get set }
    var accessToken: String? { get set }
    var hasAccount: Bool { get }

    func update(value: Any, forKey: String)

    func jsonDict() -> [String: Any]
}

open class RtmConfig: NSObject, Serializable, RtmConfigProtocol {
    open var clientId: String?
    open var redirectUri: String?
    open var userEmail: String?
    open var deviceInfo: DeviceInfo?
    open var hasAccount: Bool = false
    open var version: String?
    open var demoMode: Bool?
    open var customCSSUrl: String?
    open var demoCardGroup: String?
    open var accessToken: String?
    open var language: String?
    open var baseLanguageUrl: String?
    open var useWebCardScanner: Bool?
    
    open var customs: [String:Any]?
    
    public init(clientId:String = FitpaySDKConfiguration.defaultConfiguration.clientId,
                redirectUri:String = FitpaySDKConfiguration.defaultConfiguration.redirectUri,
                userEmail:String?,
                deviceInfo:DeviceInfo?,
                hasAccount:Bool = false) {
        self.clientId = clientId
        self.redirectUri = redirectUri
        self.userEmail = userEmail
        self.deviceInfo = deviceInfo
        self.hasAccount = hasAccount
    }

    private enum CodingKeys: String, CodingKey {
        case clientId = "clientId"
        case redirectUri = "redirectUri"
        case userEmail = "userEmail"
        case deviceInfo = "paymentDevice"
        case hasAccount = "account"
        case version = "version"
        case demoMode = "demoMode"
        case customCSSUrl = "themeOverrideCssUrl"
        case demoCardGroup = "demoCardGroup"
        case accessToken = "accessToken"
        case language = "language"
        case baseLanguageUrl = "baseLangUrl"
        case useWebCardScanner = "useWebCardScanner"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clientId = try container.decode(.clientId)
        redirectUri = try container.decode(.redirectUri)
        userEmail = try container.decode(.userEmail)
       // deviceInfo = try container.decode(.deviceInfo)
        hasAccount = try container.decode(.hasAccount) ?? false
        version = try container.decode(.version)
        demoMode = try container.decode(.demoMode)
        customCSSUrl = try container.decode(.customCSSUrl)
        demoCardGroup = try container.decode(.demoCardGroup)
        accessToken = try container.decode(.accessToken)
        language = try container.decode(.language)
        baseLanguageUrl = try container.decode(.baseLanguageUrl)
        useWebCardScanner = try container.decode(.useWebCardScanner)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(redirectUri, forKey: .redirectUri)
        try container.encode(userEmail, forKey: .userEmail)
       // try container.encode(deviceInfo, forKey: .deviceInfo)
        try container.encode(hasAccount, forKey: .hasAccount)
        try container.encode(version, forKey: .version)
        try container.encode(demoMode, forKey: .demoMode)
        try container.encode(customCSSUrl, forKey: .customCSSUrl)
        try container.encode(demoCardGroup, forKey: .demoCardGroup)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(language, forKey: .language)
        try container.encode(baseLanguageUrl, forKey: .baseLanguageUrl)
        try container.encode(useWebCardScanner, forKey: .useWebCardScanner)
    }

    public func update(value: Any, forKey key: String) {
        if let mappingKey = RtmConfigDafaultMappingKey(rawValue: key) {
            switch mappingKey {
            case .accessToken:
                accessToken = value as? String
                break
            case .clientId:
                clientId = value as? String
                break
            case .redirectUri:
                redirectUri = value as? String
                break
            case .userEmail:
                userEmail = value as? String
                break
            case .deviceInfo:
                deviceInfo = value as? DeviceInfo
                break
            case .hasAccount:
                hasAccount = value as? Bool ?? false
                break
            case .version:
                version = value as? String
                break
            case .demoMode:
                demoMode = value as? Bool
                break
            case .customCSSUrl:
                customCSSUrl = value as? String
                break
            case .demoCardGroup:
                demoCardGroup = value as? String
                break
            case .language:
                language = value as? String
                break
            case .baseLanguageUrl:
                baseLanguageUrl = value as? String
                break
            case .useWebCardScanner:
                useWebCardScanner = value as? Bool
            }
        } else {
            if customs == nil {
                customs = [:]
            }
            
            customs!.updateValue(value, forKey: key)
        }
    }
    
    public func jsonDict() -> [String: Any] {
        var dict = self.toJSON()!
        if let customs = self.customs {
            dict += customs
        }
        return dict
    }
}
