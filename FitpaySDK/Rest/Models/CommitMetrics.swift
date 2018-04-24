
public enum SyncInitiator : String, Serializable {
    case Platform = "PLATFORM"
    case Notification = "NOTIFICATION"
    case WebHook = "WEB_HOOK"
    case NotDefined = "NOT DEFINED"
}

open class CommitMetrics : Serializable
{
    public var syncId: String?
    public var deviceId: String?
    public var userId: String?
    public var sdkVersion: String?
    public var osVersion: String?
    public var initiator: SyncInitiator?
    public var totalProcessingTimeMs: Int?
    public var commitStatistics: [CommitStatistic]?
    open var notificationAsc: NotificationDetail? {
        didSet {
            self.syncId = self.notificationAsc?.syncId
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case syncId = "syncId"
        case deviceId = "deviceId"
        case userId = "userId"
        case sdkVersion = "sdkVersion"
        case osVersion = "osVersion"
        case initiator = "initiator"
        case totalProcessingTimeMs = "totalProcessingTimeMs"
        case commitStatistics = "commits"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        syncId = try container.decode(.syncId)
        userId = try container.decode(.userId)
        sdkVersion = try container.decode(.sdkVersion)
        osVersion = try container.decode(.osVersion)
        initiator = try container.decode(.initiator)
        totalProcessingTimeMs = try container.decode(.totalProcessingTimeMs)
        commitStatistics = try container.decode(.commitStatistics)
    }
    
    public init() {
        self.sdkVersion = FitpaySDKVersion
        self.osVersion = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
    }

    open func sendCompleteSync() {
        guard let completeSync = self.notificationAsc?.completeSync else {
            log.error("SYNC_ACKNOWLEDGMENT: trying to send completeSync without URL.")
            return
        }
        
        guard let client = self.notificationAsc?.restClient else {
            log.error("SYNC_ACKNOWLEDGMENT: trying to send completeSync without rest client.")
            return
        }
        
        let params = ["params": self.toJSON()]
        client.makePostCall(completeSync, parameters: params as [String: AnyObject]?) { (error) in
            if let error = error {
                log.error("SYNC_ACKNOWLEDGMENT: completeSync failed to send. Error: \(error)")
            } else {
                log.debug("SYNC_ACKNOWLEDGMENT: completeSync has been sent successfully.")
            }
        }
    }
}
