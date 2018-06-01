import Foundation

open class IdVerificationResponse: NSObject, Serializable {
    
    /// Most recent date this user updated their: Billing Address, Name, Email, password,
    /// or other Personally Identifiable Information associated to their account.
    open var oemAccountInfoUpdatedDate: Date?
    
    open var oemAccountCreatedDate: Date?
    
    /// If this user has multiple devices, 
    /// how many cards are suspended in total across all devices?
    open var suspendedCardsInOemAccount: Int?
    
    ///  Date this account was previously used, never today.
    open var lastOemAccountActivityDate: Date?
    
    /// Date this device was reported lost or stolen. Don't send if you don't have it.
    open var deviceLostModeDate: Date?
    
    open var devicesWithIdenticalActiveToken: Int?
    
    /// If this user has multiple devices,
    /// how many cards are active in total across all devices?
    open var activeTokensOnAllDevicesForOemAccount: Int?

    /// between 0-9
    open var oemAccountScore: UInt8?
    
    /// between 0-9
    open var deviceScore: UInt8?
    
    /// Only needed if your device is NOT nfcCapable
    open var nfcCapable: Bool?
    
    /// Country of user's billing address in ISO 3166-1 alpha-2 format, e.g., US; maximum 2 characters
    open var billingCountryCode: String?
    
    /// Country setting of account or phone in ISO 3166-1 alpha-2 format
    open var oemAccountCountryCode: String?
    
    /// Country setting of payment device
    open var deviceCountry: String?
    
    /// First and Last name of account
    open var oemAccountUserName: String?
    
    /// What day was this device first paired with this oemAccount?
    open var devicePairedToOemAccountDate: Date?
    
    /// Time Zone Abbreviation. Example: PDT, MST
    open var deviceTimeZone: String?
    
    /// 1 - Time Zone Set by Network
    /// 2 - Time Zone Set by User
    /// 3 - Time Zone set by Device Location.
    open var deviceTimeZoneSetBy: Int?
    
    /// Only needed if your payment device has a cell connection
    open var deviceIMEI: String?
    
    open var billingLine1: String?
    open var billingLine2: String?
    open var billingCity: String?
    open var billingState: String?
    open var billingZip: String?
    
    /// [language designator ISO-639-1]‌‌‌‌-[region designator ISO 3166-1 alpha-2]
    public private(set) var locale: String?

    //Date format for date transformation
    private let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    public override init() {
        super.init()
        updateLocale()
    }
    
    private enum CodingKeys: String, CodingKey {
        case oemAccountInfoUpdatedDate
        case oemAccountCreatedDate
        case suspendedCardsInOemAccount
        case lastOemAccountActivityDate
        case deviceLostModeDate
        case devicesWithIdenticalActiveToken
        case activeTokensOnAllDevicesForOemAccount
        case oemAccountScore
        case deviceScore
        case nfcCapable
        case billingCountryCode
        case oemAccountCountryCode
        case deviceCountry
        case oemAccountUserName
        case devicePairedToOemAccountDate
        case deviceTimeZone
        case deviceTimeZoneSetBy
        case deviceIMEI
        case billingLine1
        case billingLine2
        case billingCity
        case billingState
        case billingZip
        case locale
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        oemAccountInfoUpdatedDate = try container.decode(.oemAccountInfoUpdatedDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        oemAccountCreatedDate = try container.decode(.oemAccountCreatedDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        suspendedCardsInOemAccount = try? container.decode(.suspendedCardsInOemAccount)
        lastOemAccountActivityDate = try container.decode(.lastOemAccountActivityDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        deviceLostModeDate = try container.decode(.deviceLostModeDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        devicesWithIdenticalActiveToken = try? container.decode(.devicesWithIdenticalActiveToken)
        activeTokensOnAllDevicesForOemAccount = try? container.decode(.activeTokensOnAllDevicesForOemAccount)
        oemAccountScore = try? container.decode(.oemAccountScore)
        deviceScore = try? container.decode(.deviceScore)
        nfcCapable = try? container.decode(.nfcCapable)
        billingCountryCode = try? container.decode(.billingCountryCode)
        oemAccountCountryCode = try? container.decode(.oemAccountCountryCode)
        deviceCountry = try? container.decode(.deviceCountry)
        oemAccountUserName = try? container.decode(.oemAccountUserName)
        devicePairedToOemAccountDate = try container.decode(.devicePairedToOemAccountDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        deviceTimeZone = try? container.decode(.deviceTimeZone)
        deviceTimeZoneSetBy = try? container.decode(.deviceTimeZoneSetBy)
        deviceIMEI = try? container.decode(.deviceIMEI)
        billingLine1 = try? container.decode(.billingLine1)
        billingLine2 = try? container.decode(.billingLine2)
        billingCity = try? container.decode(.billingCity)
        billingState = try? container.decode(.billingState)
        billingZip = try? container.decode(.billingZip)
        locale = try? container.decode(.locale)

        super.init()
        updateLocale() //needed to override locale when creating from JSON
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(oemAccountInfoUpdatedDate, forKey: .oemAccountInfoUpdatedDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        try? container.encode(oemAccountCreatedDate, forKey: .oemAccountCreatedDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        try? container.encode(suspendedCardsInOemAccount, forKey: .suspendedCardsInOemAccount)
        try? container.encode(lastOemAccountActivityDate, forKey: .lastOemAccountActivityDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        try? container.encode(deviceLostModeDate, forKey: .deviceLostModeDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        try? container.encode(devicesWithIdenticalActiveToken, forKey: .devicesWithIdenticalActiveToken)
        try? container.encode(activeTokensOnAllDevicesForOemAccount, forKey: .activeTokensOnAllDevicesForOemAccount)
        try? container.encode(oemAccountScore, forKey: .oemAccountScore)
        try? container.encode(deviceScore, forKey: .deviceScore)
        try? container.encode(nfcCapable, forKey: .nfcCapable)
        try? container.encode(billingCountryCode, forKey: .billingCountryCode)
        try? container.encode(oemAccountCountryCode, forKey: .oemAccountCountryCode)
        try? container.encode(deviceCountry, forKey: .deviceCountry)
        try? container.encode(oemAccountUserName, forKey: .oemAccountUserName)
        try? container.encode(devicePairedToOemAccountDate, forKey: .devicePairedToOemAccountDate, transformer: CustomDateFormatTransform(formatString: dateFormat))
        try? container.encode(deviceTimeZone, forKey: .deviceTimeZone)
        try? container.encode(deviceTimeZoneSetBy, forKey: .deviceTimeZoneSetBy)
        try? container.encode(billingLine1, forKey: .billingLine1)
        try? container.encode(billingLine2, forKey: .billingLine2)
        try? container.encode(billingCity, forKey: .billingCity)
        try? container.encode(billingState, forKey: .billingState)
        try? container.encode(billingZip, forKey: .billingZip)
        try? container.encode(locale, forKey: .locale)
    }

    private func updateLocale() {
        guard let preferredLanguage = NSLocale.preferredLanguages.first else { return }
        guard let languageCode = NSLocale.current.languageCode else { return }
        guard let regionCode = NSLocale.current.regionCode else { return }
        
        locale = PaymentDeviceUtils.getStandardLocale(preferredLanguage: preferredLanguage, languageCode: languageCode, regionCode: regionCode)
    }

}
