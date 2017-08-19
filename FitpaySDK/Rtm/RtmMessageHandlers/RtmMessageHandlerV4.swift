//
//  RtmMessageHandlerV4.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 17.08.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation

class RtmMessageHandlerV4: RtmMessageHandlerV3 {
    var cardScanner: IFitpayCardScanner?
    
    enum RtmMessageTypeVer3: RtmMessageType, RtmMessageTypeWithHandler {
        case rtmVersion   = "version"
        case sync         = "sync"
        case deviceStatus = "deviceStatus"
        case userData     = "userData"
        case logout       = "logout"
        case resolve      = "resolve"
        case scanRequest  = "scanRequest"
        case cardScanned  = "cardScanned"
        
        func msgHandlerFor(handlerObject: RtmMessageHandler) -> MessageTypeHandler? {
            guard let handlerObject = handlerObject as? RtmMessageHandlerV4 else {
                return nil
            }
            
            switch self {
            case .userData:
                return handlerObject.handleSessionData
            case .sync:
                return handlerObject.handleSync
            case .scanRequest:
                return handlerObject.handleScanRequest
            case .deviceStatus,
                 .logout,
                 .resolve,
                 .rtmVersion,
                 .cardScanned:
                return nil
            }
        }
    }
    
    override func handlerFor(rtmMessage: RtmMessageType) -> MessageTypeHandler? {
        guard let messageAction = RtmMessageTypeVer3(rawValue: rtmMessage) else {
            log.debug("WV_DATA: RtmMessage. Action is missing or unknown: \(rtmMessage)")
            return nil
        }
        
        return messageAction.msgHandlerFor(handlerObject: self)
    }
    
    func handleScanRequest(_ message: RtmMessage) {
        if let cardScannerDataSource = self.cardScannerDataSource {
            self.cardScanner = cardScannerDataSource.cardScanner()
            self.cardScanner?.scanDelegate = self
            if let cardScannerPresenter = self.cardScannerPresenterDelegate {
                cardScannerPresenter.shouldPresentCardScanner(scanner: self.cardScanner!)
            }
        }
    }
}

extension RtmMessageHandlerV4: FitpayCardScannerDelegate {
    func scanned(card: ScannedCardInfo?, error: Error?) {
        if let delegate = self.outputDelegate {
            delegate.send(rtmMessage: RtmMessageResponse(data: card?.toJSON(), type: RtmMessageTypeVer3.cardScanned.rawValue, success: true), retries: 3)
        }
        
        if let cardScannerPresenter = self.cardScannerPresenterDelegate, let cardScanner = self.cardScanner {
            cardScannerPresenter.shouldDissmissCardScanner(scanner: cardScanner)
        }
    }
    
    func canceled() {
        if let cardScannerPresenter = self.cardScannerPresenterDelegate, let cardScanner = self.cardScanner {
            cardScannerPresenter.shouldDissmissCardScanner(scanner: cardScanner)
        }
    }
}
