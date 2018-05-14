
public enum SyncInitiator : String, Serializable {
    case Platform = "PLATFORM"
    case Notification = "NOTIFICATION"
    case WebHook = "WEB_HOOK"
    case EventStream = "EVENT_STREAM"
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
        case syncId
        case deviceId
        case userId
        case sdkVersion
        case osVersion
        case initiator
        case totalProcessingTimeMs
        case commitStatistics = "commits"
    }
    
    public init() {
        self.sdkVersion = FitpaySDKConfiguration.sdkVersion
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
        client.makePostCall(completeSync, parameters: params as [String: Any]?) { (error) in
            if let error = error {
                log.error("SYNC_ACKNOWLEDGMENT: completeSync failed to send. Error: \(error)")
            } else {
                log.debug("SYNC_ACKNOWLEDGMENT: completeSync has been sent successfully.")
            }
        }
    }
}
