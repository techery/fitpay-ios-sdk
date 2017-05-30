//
//  RtmMessageHandlerV3.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 30.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation



class RtmMessageHandlerV3: RtmMessageHandlerV2 {
    
    var cardScanner: IFitpayCardScanner?
    
    enum RtmMessageTypeVer3: RtmMessageType, RtmMessageTypeWithHandler {
        case rtmVersion   = "version"
        case sync         = "sync"
        case deviceStatus = "deviceStatus"
        case userData     = "userData"
        case logout       = "logout"
        case resolve      = "resolve"
        case scanRequest  = "scanRequest"
        
        func msgHandlerFor(handlerObject: RtmMessageHandler) -> MessageTypeHandler? {
            guard let handlerObject = handlerObject as? RtmMessageHandlerV3 else {
                return nil
            }
            
            switch self {
            case .userData:
                return handlerObject.handleSessionData
            case .sync:
                return handlerObject.handleSync
            case .scanRequest:
                return handlerObject.handleScanRequest
            case .deviceStatus, .logout, .resolve, .rtmVersion:
                return nil
            }
        }
    }
    
    override func handlerFor(rtmMessage: RtmMessageType) -> MessageTypeHandler? {
        guard let messageAction = RtmMessageTypeVer3(rawValue: rtmMessage) else {
            log.error("WV_DATA: RtmMessage. Action is missing or unknown: \(rtmMessage)")
            return nil
        }
        
        return messageAction.msgHandlerFor(handlerObject: self)
    }
    
    func handleScanRequest(_ message: RtmMessage) {
        if let cardScannerDataSource = self.wvConfig.cardScannerDataSource {
            let scanner = cardScannerDataSource.cardScanner()
            if let cardScannerPresenter = self.wvConfig.cardScannerPresenterDelegate {
                cardScannerPresenter.shouldPresentCardScanner(scanner: scanner)
            }
        }
    }
}
