//
//  RtmMessageHandlerV5.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 30.08.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

class RtmMessageHandlerV5: RtmMessageHandlerV4 {
    enum RtmMessageTypeVer5: RtmMessageType, RtmMessageTypeWithHandler {
        case rtmVersion            = "version"
        case sync                  = "sync"
        case deviceStatus          = "deviceStatus"
        case userData              = "userData"
        case logout                = "logout"
        case resolve               = "resolve"
        case scanRequest           = "scanRequest"
        case cardScanned           = "cardScanned"
        case sdkVersionRequest     = "sdkVersionRequest"
        case sdkVersion            = "sdkVersion"
        case idVerificationRequest = "idVerificationRequest"
        case idVerification        = "idVerification"
        
        func msgHandlerFor(handlerObject: RtmMessageHandler) -> MessageTypeHandler? {
            guard let handlerObject = handlerObject as? RtmMessageHandlerV5 else {
                return nil
            }
            
            switch self {
            case .userData:
                return handlerObject.handleSessionData
            case .sync:
                return handlerObject.handleSync
            case .scanRequest:
                return handlerObject.handleScanRequest
            case .sdkVersionRequest:
                return handlerObject.handleSdkVersion
            case .idVerificationRequest:
                return handlerObject.handleIdVerificationRequest
            case .deviceStatus,
                 .logout,
                 .resolve,
                 .rtmVersion,
                 .cardScanned,
                 .sdkVersion,
                 .idVerification:
                return nil
            }
        }
    }
    
    override func handlerFor(rtmMessage: RtmMessageType) -> MessageTypeHandler? {
        guard let messageAction = RtmMessageTypeVer5(rawValue: rtmMessage) else {
            log.debug("WV_DATA: RtmMessage. Action is missing or unknown: \(rtmMessage)")
            return nil
        }
        
        return messageAction.msgHandlerFor(handlerObject: self)
    }
    
    func handleIdVerificationRequest(_ message: RtmMessage) {
        wvConfigStorage.paymentDevice?.handleIdVerificationRequest(completion: { [weak self] (response) in
            if let delegate = self?.outputDelegate {
                delegate.send(rtmMessage: RtmMessageResponse(data: response.toJSON(), type: RtmMessageTypeVer5.idVerification.rawValue, success: true), retries: 3)
            }
        })
    }
}
