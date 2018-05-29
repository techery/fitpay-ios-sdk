//
//  BindedToDeviceSyncRequestQueue.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 13.07.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

class BindedToDeviceSyncRequestQueue {
    init(deviceInfo: DeviceInfo?, syncManager: SyncManagerProtocol) {
        self.deviceInfo = deviceInfo
        self.syncManager = syncManager
    }
    
    func add(request: SyncRequest) {
        let sizeOfQueue = self.requestsQueue.count
        
        self.requestsQueue.enqueue(request)
        
        var isSyncManagerBusy = false
        if syncManager.synchronousModeOn {
            isSyncManagerBusy = syncManager.isSyncing
        }
        
        if isSyncManagerBusy == false && sizeOfQueue == 0 {
            if let error = self.startSyncFor(request: request) {
                self.syncCompletedFor(request: request, withStatus: .failed, andError: error)
            }
        }
    }
    
    func syncCompletedFor(request: SyncRequest, withStatus status: EventStatus, andError error: Error?) {
        guard let queuedRequest = self.requestsQueue.dequeue() else {
            return
        }
        
        guard queuedRequest.isSameUserAndDevice(otherRequest: request) else {
            log.error("Error. Queued sync request is different from completed.")
            return
        }
        
        request.update(state: .done)
        request.syncCompleteWith(status: status, error: error)
        
        // outdated requests should also become completed, because we already processed their commits
        while let outdateRequest = self.requestsQueue.peekAtQueue() {
            if outdateRequest.requestTime.timeIntervalSince1970 < request.syncStartTime!.timeIntervalSince1970 &&
                request.isSameUserAndDevice(otherRequest: outdateRequest) {
                let _ = self.requestsQueue.dequeue()
                outdateRequest.update(state: .done)
                outdateRequest.syncCompleteWith(status: status, error: error)
            } else {
                break
            }
        }
        
        processNext()

    }
    
    func dequeue() -> SyncRequest? {
        return self.requestsQueue.dequeue()
    }
    
    private var requestsQueue: [SyncRequest] = []
    private var deviceInfo: DeviceInfo?
    private var syncManager: SyncManagerProtocol
    
    private func startSyncFor(request: SyncRequest) -> NSError? {
        request.update(state: .inProgress)
        
        var errorObj: NSError? = nil
        if request.user != nil {
            do {
                try self.syncManager.syncWith(request: request)
            } catch {
                errorObj = error as NSError
            }
        } else {
            errorObj = NSError.error(code: 0, domain: BindedToDeviceSyncRequestQueue.self, message: "Can't start sync with empty user")
        }
        
        return errorObj
    }
    
    private func processNext() {
        guard let request = requestsQueue.peekAtQueue() else { return }
        
        if let error = startSyncFor(request: request) {
            syncCompletedFor(request: request, withStatus: .failed, andError: error)
        }
    }

}
