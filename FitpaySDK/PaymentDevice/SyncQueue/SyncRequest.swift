//
//  SyncRequest.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 13.07.17.
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
    
    /// Creates sync request. If you are using parallel sync mode,
    /// then make sure that you are passing all params.
    ///
    /// - Parameters:
    ///   - requestTime: time when request was made. Used for filtering unnecessary syncs.
    ///   - user: user object. If nil then will be used user from previous sync.
    ///           You can use nil only for synchronous sync mode.
    ///   - deviceInfo: device info object. If nil then will be used device info from previous sync.
    ///           You can use nil only for synchronous sync mode.
    ///   - paymentDevice: payment device object. If nil then will be used payment device from previous sync.
    ///           You can use nil only for synchronous sync mode.
    init(requestTime: Date = Date(),
         user: User? = nil,
         deviceInfo: DeviceInfo? = nil,
         paymentDevice: PaymentDevice? = nil) {
        
        if SyncRequest.syncManager.synchronousModeOn == false {
            if (user != nil && deviceInfo != nil && paymentDevice != nil) == false {
                assert(false, "You should pass all params to SyncRequest in parallel sync mode.")
            }
        }
        
        self.requestTime = requestTime
        self.user = user
        self.deviceInfo = deviceInfo
        self.paymentDevice = paymentDevice
    }
    
    public let requestTime: Date
    public private(set) var syncStartTime: Date?
    
    internal let user: User?
    internal let deviceInfo: DeviceInfo?
    internal let paymentDevice: PaymentDevice?
    internal var completion: SyncRequestCompletion?
    
    internal static var syncManager: SyncManagerProtocol = SyncManager.sharedInstance
    
    private var state = SyncRequestState.pending
    
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
        return user?.id == otherRequest.user?.id && deviceInfo?.deviceIdentifier == otherRequest.deviceInfo?.deviceIdentifier
    }
}
