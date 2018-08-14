import Foundation

open class SyncRequestQueue {
    
    public static let sharedInstance = SyncRequestQueue(syncManager: SyncManager.sharedInstance)
    
    var lastFullSyncRequest: SyncRequest?

    private typealias DeviceIdentifier = String
    private var queues: [DeviceIdentifier: BindedToDeviceSyncRequestQueue] = [:]
    private let syncManager: SyncManagerProtocol
    private var bindings: [FitpayEventBinding] = []
    
    // MARK: - Lifecycle
    
    // used for dependency injection
    init(syncManager: SyncManagerProtocol) {
        self.syncManager = syncManager
        bind()
    }
    
    deinit {
        unbind()
    }

    // MARK: - Public Functions
    
    public func add(request: SyncRequest, completion: SyncRequestCompletion?) {
        request.completion = completion
        request.update(state: .pending)
        
        guard let queue = queueFor(syncRequest: request) else {
            log.error("Error. Can't get/create sync request queue for device. Device id: \(request.deviceInfo?.deviceIdentifier ?? "nil")")
            request.update(state: .done)

            completion?(.failed, SyncRequestQueueError.cantCreateQueueForSyncRequest)
            
            return
        }
        
        if !request.isEmptyRequest {
            lastFullSyncRequest = request
            lastFullSyncRequest?.deviceInfo?.updateNotificationTokenIfNeeded()
        }
        
        queue.add(request: request)
    }
    
    // MARK: - Private Functins
    
    private func queueFor(syncRequest: SyncRequest) -> BindedToDeviceSyncRequestQueue? {
        guard let deviceId = syncRequest.deviceInfo?.deviceIdentifier else { //TODO: should really check for user / device
            log.warning("Searching queue for SyncRequest without deviceIdentifier (empty SyncRequests is deprecated)... ")
            return queueForDeviceWithoutDeviceIdentifier(syncRequest: syncRequest)
        }
        
        return queues[deviceId] ?? createNewQueueFor(deviceId: deviceId, syncRequest: syncRequest)
    }
    
    private func createNewQueueFor(deviceId: DeviceIdentifier, syncRequest: SyncRequest) -> BindedToDeviceSyncRequestQueue? {
        let queue = BindedToDeviceSyncRequestQueue(syncManager: syncManager)
        queues[deviceId] = queue
        
        return queue
    }
    
    private func queueForDeviceWithoutDeviceIdentifier(syncRequest: SyncRequest) -> BindedToDeviceSyncRequestQueue? {
        log.warning("Searching queue for SyncRequest without deviceIdentifier (empty SyncRequests is deprecated)... ")
        guard let lastFullSyncRequest = self.lastFullSyncRequest else {
            log.error("Can't find queue for empty SyncRequest")
            return nil
        }
        
        syncRequest.user = lastFullSyncRequest.user
        syncRequest.deviceInfo = lastFullSyncRequest.deviceInfo
        syncRequest.paymentDevice = lastFullSyncRequest.paymentDevice
        
        log.warning("Putting SyncRequest without deviceIdentifier to the queue with deviceIdentifier - \(syncRequest.deviceInfo?.deviceIdentifier ?? "none")")
        return queueFor(syncRequest: syncRequest)
    }
    
    private func bind() {
        var binding = self.syncManager.bindToSyncEvent(eventType: .syncCompleted) { [weak self] (event) in
            guard let request = (event.eventData as? [String: Any])?["request"] as? SyncRequest else {
                log.warning("Can't get request from sync event.")
                return
            }
            
            if let queue = self?.queueFor(syncRequest: request) {
                queue.syncCompletedFor(request: request, withStatus: .success, andError: nil)
            }
        }
        
        if let binding = binding {
            self.bindings.append(binding)
        }
        
        binding = self.syncManager.bindToSyncEvent(eventType: .syncFailed) { [weak self] (event) in
            guard let request = (event.eventData as? [String: Any])?["request"] as? SyncRequest else {
                log.warning("Can't get request from sync event.")
                return
            }
            
            if let queue = self?.queueFor(syncRequest: request) {
                queue.syncCompletedFor(request: request, withStatus: .failed, andError: (event.eventData as? [String: Any])?["error"] as? NSError)
            }
        }
        
        if let binding = binding {
            self.bindings.append(binding)
        }
    }
    
    private func unbind() {
        for binding in self.bindings {
            self.syncManager.removeSyncBinding(binding: binding)
        }
    }
    
}

extension SyncRequestQueue {
    enum SyncRequestQueueError: Error {
        case cantCreateQueueForSyncRequest
    }
}
