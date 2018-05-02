
public enum APDUPackageResponseState : String {
    case processed    = "PROCESSED"
    case failed       = "FAILED"
    case error        = "ERROR"
    case expired      = "EXPIRED"
    case notProcessed = "NOT_PROCESSED"
}

@objcMembers
open class ApduPackage : NSObject, Serializable
{
    internal var links: [ResourceLink]?
    open var seIdType: String?
    open var targetDeviceType: String?
    open var targetDeviceId: String?
    open var packageId: String?
    open var seId: String?
    open var targetAid: String?
    open var apduCommands: [APDUCommand]?

    open var state: APDUPackageResponseState?
    open var executedEpoch: TimeInterval?
    open var executedDuration: Int?

    open var validUntil: String?
    open var validUntilEpoch: Date?
    open var apduPackageUrl: String?
    
    @objc open static var APDUPackageResponseStateProcessed: String
    {
        return APDUPackageResponseState.processed.rawValue
    }
    @objc open static var APDUPackageResponseStateFailed: String
    {
        return APDUPackageResponseState.failed.rawValue
    }
    @objc open static var APDUPackageResponseStateError: String
    {
        return APDUPackageResponseState.error.rawValue
    }
    @objc open static var APDUPackageResponseStateExpired: String
    {
        return APDUPackageResponseState.expired.rawValue
    }
    @objc open static var APDUPackageResponseStateNotProcessed: String
    {
        return APDUPackageResponseState.notProcessed.rawValue
    }

    override init() {
        super.init()
    }

    private enum CodingKeys: String, CodingKey {
        case links = "_links"
        case seIdType = "seIdType"
        case targetDeviceType = "targetDeviceType"
        case targetDeviceId = "targetDeviceId"
        case packageId = "packageId"
        case seId = "seId"
        case apduCommands = "commandApdus"
        case validUntil = "validUntil"
        case apduPackageUrl = "apduPackageUrl"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        links = try container.decode(.links, transformer: ResourceLinkTypeTransform())
        seIdType = try container.decode(.seIdType)
        targetDeviceType = try container.decode(.targetDeviceType)
        targetDeviceId = try container.decode(.targetDeviceId)
        packageId = try container.decode(.packageId)
        seId = try container.decode(.seId)
        apduCommands = try container.decode(.apduCommands)
        validUntil = try container.decode(.validUntil)
        validUntilEpoch = try container.decode(.validUntil, transformer: CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSX"))
        apduPackageUrl = try container.decode(.apduPackageUrl)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(links, forKey: .links, transformer: ResourceLinkTypeTransform())
        try container.encode(seIdType, forKey: .seIdType)
        try container.encode(targetDeviceType, forKey: .targetDeviceType)
        try container.encode(targetDeviceId, forKey: .targetDeviceId)
        try container.encode(packageId, forKey: .packageId)
        try container.encode(apduCommands, forKey: .apduCommands)
        try container.encode(validUntil, forKey: .validUntil)
        try container.encode(validUntilEpoch, forKey: .validUntil, transformer: CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSSX"))
        try container.encode(apduPackageUrl, forKey: .apduPackageUrl)
    }

    open var isExpired: Bool {
        guard let validUntilEpoch = self.validUntilEpoch else {
            return false
        }
        
        return validUntilEpoch <= Date()
    }

    open var responseDictionary: [String: Any] {
        get {
            var dic: [String: Any] = [:]

            if let packageId = self.packageId {
                dic["packageId"] = packageId
            }

            if let state = self.state {
                dic["state"] = state.rawValue
            }

            if let executed = self.executedEpoch {
                dic["executedTsEpoch"] = Int64(executed * 1000)
            }

            if let executedDuration = self.executedDuration {
                dic["executedDuration"] = executedDuration
            }

            if state == APDUPackageResponseState.expired {
                dic["apduResponses"] = []
                return dic
            }

            if let apduResponses = self.apduCommands {
                if apduResponses.count > 0 {
                    var responsesArray: [Any] = []
                    for resp in apduResponses {
                        if let _ = resp.responseData {
                            responsesArray.append(resp.responseDictionary)
                        }
                    }

                    dic["apduResponses"] = responsesArray
                }
            }

            return dic
        }
    }

}

