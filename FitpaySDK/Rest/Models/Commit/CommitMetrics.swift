import Foundation

import Alamofire

open class CommitMetrics: Serializable {
    public var syncId: String?
    public var deviceId: String?
    public var userId: String?
    public var sdkVersion: String?
    public var osVersion: String?
    public var initiator: SyncInitiator?
    public var totalProcessingTimeMs: Int?
    public var commitStatistics: [CommitStatistic]?
    
    open var notification: NotificationDetail? {
        didSet {
            self.syncId = self.notification?.syncId
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

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        syncId = try container.decode(.syncId)
        deviceId = try container.decode(.deviceId)
        userId = try container.decode(.userId)
        sdkVersion = try container.decode(.sdkVersion)
        osVersion = try container.decode(.osVersion)
        initiator = try container.decode(.initiator)
        totalProcessingTimeMs = try container.decode(.totalProcessingTimeMs)
        commitStatistics = try container.decode(.commitStatistics)
    }
    
    public init() {
        self.sdkVersion = FitpayConfig.sdkVersion
        self.osVersion = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
    }

    open func sendCompleteSync() {
        guard let completeSync = notification?.links?.url("completeSync") else {
            log.error("SYNC_ACKNOWLEDGMENT: trying to send completeSync without URL.")
            return
        }
        
        guard let client = notification?.restClient else {
            log.error("SYNC_ACKNOWLEDGMENT: trying to send completeSync without rest client.")
            return
        }
        
        let params: [String: Any]? = self.toJSON() != nil ? ["params": self.toJSON()!] : nil
         client.makePostCall(completeSync, parameters: params, encoding: JSONEncoding.default) { (error) in
            if let error = error {
                log.error("SYNC_ACKNOWLEDGMENT: completeSync failed to send. Error: \(error)")
            } else if let syncId = self.syncId {
                log.debug("SYNC_ACKNOWLEDGMENT: completeSync has been sent successfully. \(syncId)")
            }
        }
    }
}
