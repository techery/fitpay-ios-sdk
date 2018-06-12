
open class NotificationDetail: Serializable {
    
    open var ackSync: String?
    open var completeSync: String?
    open var type: String?
    open var syncId: String?
    open var deviceId: String?
    open var userId: String?
    open var clientId: String?
    
    var restClient: RestClientInterface?

    private enum CodingKeys: String, CodingKey {
        case ackSync = "_links.ackSync.href"
        case completeSync = "_links.completeSync.href"
        case type
        case syncId = "id"
        case deviceId
        case userId
        case clientId
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

