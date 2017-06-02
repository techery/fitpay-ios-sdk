//
//  SyncRequestsQueue.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 23.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

enum SyncRequestState: Int {
    case pending
    case inProgress
    case done
}

typealias SyncRequestCompletion = (EventStatus, Error?) -> Void

open class SyncRequest {
    public let requestTime: Date
    public private(set) var syncStartTime: Date?
    
    fileprivate let user: User?
    fileprivate let device: DeviceInfo?
    fileprivate let deviceConnector: IPaymentDeviceConnector?
    fileprivate var completion: SyncRequestCompletion?
    
    fileprivate var state = SyncRequestState.pending
    
    
    init(requestTime: Date = Date(),
         user: User? = nil,
         device: DeviceInfo? = nil,
         deviceConnector: IPaymentDeviceConnector? = nil) {
        self.requestTime = requestTime
        self.user = user
        self.device = device
        self.deviceConnector = deviceConnector
    }
    
    internal func update(state: SyncRequestState) {
        if state == .inProgress {
            self.syncStartTime = Date()
        }
        
        self.state = state
    }
    
    internal func syncCompleteWith(status: EventStatus, error: Error?) {
        if let completion = self.completion {
            completion(status, error)
        }
    }
    
    func isSameUserAndDevice(otherRequest: SyncRequest) -> Bool {
        return user?.id == otherRequest.user?.id && device?.deviceIdentifier == otherRequest.device?.deviceIdentifier
    }
}

open class SyncRequestQueue {
    static let sharedInstance = SyncRequestQueue(syncManager: SyncManager.sharedInstance)

    fileprivate let syncManager: SyncManagerProtocol
    internal var requestsQueue: [SyncRequest] = []
    
    fileprivate var bindings: [FitpayEventBinding] = []
    
    init(syncManager: SyncManagerProtocol) {
        self.syncManager = syncManager
        self.bind()
    }
    
    deinit {
        self.unbind()
    }
    
    func add(request: SyncRequest, completion: SyncRequestCompletion?) {
        request.completion = completion
        request.update(state: .pending)
        let sizeOfQueue = self.requestsQueue.count
        
        self.requestsQueue.enqueue(request)
        
        if self.syncManager.isSyncing == false && sizeOfQueue == 0 {
            if let error = self.startSyncFor(request: request) {
                self.lastSyncCompleteWith(status: .failed, error: error)
            }
        }
    }
    
    fileprivate func bind() {
        var binding = self.syncManager.bindToSyncEvent(eventType: .syncCompleted) { [weak self] (event) in
            if let request = self?.requestsQueue.peekAtQueue() {
                if request.state == .inProgress {
                    self?.lastSyncCompleteWith(status: .success, error: nil)
                } else {
                    self?.processNext()
                }
            }
        }
        
        if let binding = binding {
            self.bindings.append(binding)
        }
        
        binding = self.syncManager.bindToSyncEvent(eventType: .syncFailed) { [weak self] (event) in
            if let request = self?.requestsQueue.peekAtQueue() {
                if request.state == .inProgress {
                    self?.lastSyncCompleteWith(status: .failed, error: (event.eventData as? [String: NSError])?["error"])
                } else {
                    self?.processNext()
                }
            }
        }
        
        if let binding = binding {
            self.bindings.append(binding)
        }
    }
    
    
    fileprivate func unbind() {
        for binding in self.bindings {
            self.syncManager.removeSyncBinding(binding: binding)
        }
    }
    
    fileprivate func processNext() {
        guard let request = self.requestsQueue.peekAtQueue() else {
            return
        }
        
        // giving some time for direct sync call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let error = self?.startSyncFor(request: request) {
                self?.lastSyncCompleteWith(status: .failed, error: error)
            }
        }
    }
    
    fileprivate func startSyncFor(request: SyncRequest) -> NSError? {
        request.update(state: .inProgress)
        
        let user = request.user
        
        let error: NSError?
        if let user = user {
            error = self.syncManager.sync(user, device: request.device, deviceConnector: request.deviceConnector)
        } else {
            error = self.syncManager.tryToMakeSyncWithLastUser()
        }
        
        return error
    }
    
    fileprivate func lastSyncCompleteWith(status: EventStatus, error: Error?) {
        guard let request = self.requestsQueue.dequeue() else {
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
}
