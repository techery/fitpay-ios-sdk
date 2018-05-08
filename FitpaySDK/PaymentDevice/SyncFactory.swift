//
//  SyncFactory.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 16.08.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

public protocol SyncFactory {
    func commitsFetcherOperationWith(deviceInfo: DeviceInfo, connector: PaymentDeviceConnectable?) -> FetchCommitsOperationProtocol
    func apduConfirmOperation() -> APDUConfirmOperationProtocol
    func nonApduConfirmOperation() -> NonAPDUConfirmOperationProtocol
    func connectDeviceOperationWith(paymentDevice: PaymentDevice) -> ConnectDeviceOperationProtocol
}

extension SyncFactory {
    func commitsFetcherOperationWith(deviceInfo: DeviceInfo, connector: PaymentDeviceConnectable?) -> FetchCommitsOperationProtocol {
        return FetchCommitsOperation(deviceInfo: deviceInfo, shouldStartFromSyncedCommit: true, syncStorage: SyncStorage.sharedInstance, connector: connector)
    }
    
    func apduConfirmOperation() -> APDUConfirmOperationProtocol {
        return APDUConfirmOperation()
    }
    
    func nonApduConfirmOperation() -> NonAPDUConfirmOperationProtocol {
        return NonAPDUConfirmOperation()
    }
    
    func connectDeviceOperationWith(paymentDevice: PaymentDevice) -> ConnectDeviceOperationProtocol {
        return ConnectDeviceOperation(paymentDevice: paymentDevice)
    }
}

class DefaultSyncFactory: SyncFactory {}
