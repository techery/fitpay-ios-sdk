
open class NotificationDetail : Serializable
{
    open var ackSync: String?
    open var completeSync: String?
    open var type: String?
    open var syncId: String?
    open var deviceId: String?
    open var userId: String?
    open var clientId: String?
    var restClient:RestClient?

    private enum CodingKeys: String, CodingKey {
        case ackSync = "_links.ackSync.href"
        case completeSync = "_links.completeSync.href"
        case type = "type"
        case syncId = "id"
        case deviceId = "deviceId"
        case userId = "userId"
        case clientId = "clientId"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ackSync = try container.decode(.ackSync)
        completeSync = try container.decode(.completeSync)
        type = try container.decode(.type)
        syncId = try container.decode(.syncId)
        deviceId = try container.decode(.deviceId)
        userId = try container.decode(.userId)
        clientId = try container.decode(.clientId)
    }
    
    open func sendAckSync() {
        guard let ackSync = self.ackSync else {
            log.error("SYNC_ACKNOWLEDGMENT: trying to send ackSync without URL.")
            return
        }

        guard let client = self.restClient else {
            log.error("SYNC_ACKNOWLEDGMENT: trying to send ackSync without rest client.")
            return
        }

        client.makePostCall(ackSync, parameters:nil) { (error) in
            if let error = error {
                log.error("SYNC_ACKNOWLEDGMENT: ackSync failed to send. Error: \(error)")
            } else {
                log.debug("SYNC_ACKNOWLEDGMENT: ackSync has been sent successfully.")
            }
        }
    }
}

