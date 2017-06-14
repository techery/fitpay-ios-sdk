//
//  SyncRequestsQueueTests.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 24.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import XCTest
@testable import FitpaySDK


class MockSyncManager: SyncManagerProtocol {
    var isSyncing: Bool = false
    fileprivate let eventsDispatcher = FitpayEventDispatcher()
    static var syncCompleteDelay: Double = 0.2

    func sync(_ user: User, device: DeviceInfo?, deviceConnector: IPaymentDeviceConnector? = nil) -> NSError? {
        if isSyncing {
            return NSError.unhandledError(MockSyncManager.self)
        }
        
        self.startSync()
        
        return nil
    }
    
    func tryToMakeSyncWithLastUser() -> NSError? {
        if isSyncing {
            return NSError.unhandledError(MockSyncManager.self)
        }
        
        self.startSync()
        
        return nil
    }
    
    func bindToSyncEvent(eventType: SyncEventType, completion: @escaping SyncEventBlockHandler) -> FitpayEventBinding? {
        return eventsDispatcher.addListenerToEvent(FitpayBlockEventListener(completion: completion), eventId: eventType)
    }
    
    func removeSyncBinding(binding: FitpayEventBinding) {
        eventsDispatcher.removeBinding(binding)
    }
    
    func callCompletionForSyncEvent(_ event: SyncEventType, params: [String: Any]) {
        eventsDispatcher.dispatchEvent(FitpayEvent(eventId: event, eventData: params))
    }

    func startSync() {
        self.isSyncing = true

        DispatchQueue.main.asyncAfter(deadline: self.delayForSync) { [weak self] in
            self?.isSyncing = false
            self?.callCompletionForSyncEvent(.syncCompleted, params: [:])
        }
    }
    
    var delayForSync: DispatchTime {
        return .now() + MockSyncManager.syncCompleteDelay
    }
}

class MockFailedSyncManger: MockSyncManager {
    override func startSync() {
        self.isSyncing = true
        
        DispatchQueue.main.asyncAfter(deadline: self.delayForSync) { [weak self] in
            self?.isSyncing = false
            self?.callCompletionForSyncEvent(.syncFailed, params: ["error":NSError.unhandledError(MockFailedSyncManger.self)])
        }
    }
}


class SyncRequestsQueueTests: XCTestCase {
    var requestsQueue: SyncRequestQueue!
    
    override func setUp() {
        super.setUp()
        self.requestsQueue = SyncRequestQueue(syncManager: MockSyncManager())
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMake1SuccessSync() {
        let expectation = super.expectation(description: "making 1 success sync")

        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(status, .success)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        
        super.waitForExpectations(timeout: MockSyncManager.syncCompleteDelay + 1, handler: nil)
    }
    
    func testMake1FailedSync() {
        
        self.requestsQueue = SyncRequestQueue(syncManager: MockFailedSyncManger())

        let expectation = super.expectation(description: "making 1 failed sync")
        
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(status, .failed)
            XCTAssertNotNil(error)
            
            expectation.fulfill()
        }
        
        super.waitForExpectations(timeout: MockSyncManager.syncCompleteDelay + 1, handler: nil)

    }
    
    func testSuccessQueueOrder() {
        let expectation = super.expectation(description: "making success queue")
        
        MockSyncManager.syncCompleteDelay = 0.05
        
        var counter = 0
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 0)
            XCTAssertEqual(status, .success)
            XCTAssertNil(error)
            counter += 1
        }
        
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 1)
            XCTAssertEqual(status, .success)
            XCTAssertNil(error)
            counter += 1
        }
        
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 2)
            XCTAssertEqual(status, .success)
            XCTAssertNil(error)
            counter += 1
            
            expectation.fulfill()
        }
        
        super.waitForExpectations(timeout: MockSyncManager.syncCompleteDelay * 3 + 1, handler: nil)
    }
    
    func testFailedQueueOrder() {
        self.requestsQueue = SyncRequestQueue(syncManager: MockFailedSyncManger())

        let expectation = super.expectation(description: "making failed queue")
        
        MockSyncManager.syncCompleteDelay = 0.02
        
        var counter = 0
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 0)
            XCTAssertEqual(status, .failed)
            XCTAssertNotNil(error)
            counter += 1
        }
        
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 1)
            XCTAssertEqual(status, .failed)
            XCTAssertNotNil(error)
            counter += 1
        }
        
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 2)
            XCTAssertEqual(status, .failed)
            XCTAssertNotNil(error)
            counter += 1
            
            expectation.fulfill()
        }
        
        super.waitForExpectations(timeout: MockSyncManager.syncCompleteDelay * 3 + 1, handler: nil)
    }
    
    func testQueueOrderWithAsyncInsert() {
        let expectation = super.expectation(description: "making success queue")
        
        MockSyncManager.syncCompleteDelay = 0.02
        
        var counter = 0
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 0)
            XCTAssertEqual(status, .success)
            XCTAssertNil(error)
            counter += 1
            
            self.requestsQueue.add(request: SyncRequest()) { (status, error) in
                XCTAssertEqual(counter, 3)
                XCTAssertEqual(status, .success)
                XCTAssertNil(error)
                counter += 1
                
                expectation.fulfill()
            }
        }
        
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 1)
            XCTAssertEqual(status, .success)
            XCTAssertNil(error)
            counter += 1
        }
        
        self.requestsQueue.add(request: SyncRequest()) { (status, error) in
            XCTAssertEqual(counter, 2)
            XCTAssertEqual(status, .success)
            XCTAssertNil(error)
            counter += 1
        }
        
        super.waitForExpectations(timeout: MockSyncManager.syncCompleteDelay * 5 + 1, handler: nil)
    }
}
