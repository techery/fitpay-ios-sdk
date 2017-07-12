//
//  RtmMessageHandlerV2.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 30.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import ObjectMapper

class RtmMessageHandlerV2: NSObject, RtmMessageHandler {
    
    enum RtmMessageTypeVer2: RtmMessageType, RtmMessageTypeWithHandler {
        case rtmVersion   = "version"
        case sync         = "sync"
        case deviceStatus = "deviceStatus"
        case userData     = "userData"
        case logout       = "logout"
        case resolve      = "resolve"
        
        func msgHandlerFor(handlerObject: RtmMessageHandler) -> MessageTypeHandler? {
            switch self {
            case .userData:
                return handlerObject.handleSessionData
            case .sync:
                return handlerObject.handleSync
            case .deviceStatus, .logout, .resolve, .rtmVersion:
                return nil
            }
        }
    }
    
    weak var wvConfig: WvConfig!
    
    var syncCallBacks = [RtmMessage]()
    
    required init(wvConfig: WvConfig) {
        self.wvConfig = wvConfig
    }
    
    func handle(message: [String : Any]) {
        let jsonData = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        
        guard let rtmMessage = Mapper<RtmMessage>().map(JSONString: String(data: jsonData!, encoding: .utf8)!) else {
            log.error("WV_DATA: Can't create RtmMessage.")
            return
        }
        
        if let handler = self.handlerFor(rtmMessage: rtmMessage.type ?? "") {
            handler(rtmMessage)
        }
    }
    
    func handlerFor(rtmMessage: RtmMessageType) -> MessageTypeHandler? {
        guard let messageAction = RtmMessageTypeVer2(rawValue: rtmMessage ) else {
            log.error("WV_DATA: RtmMessage. Action is missing or unknown: \(rtmMessage)")
            return nil
        }
        
        return messageAction.msgHandlerFor(handlerObject: self)
    }
    
    func handleSync(_ message: RtmMessage) {
        log.verbose("WV_DATA: Handling rtm sync.")
        if (self.wvConfig.webViewSessionData != nil && self.wvConfig.user != nil ) {
            log.verbose("WV_DATA: Adding sync to rtm callback queue.")
            syncCallBacks.append(message)
            log.verbose("WV_DATA: initiating sync.")
            SyncRequestQueue.sharedInstance.add(request: SyncRequest(user: self.wvConfig.user!, deviceInfo: self.wvConfig.device, paymentDevice: wvConfig.paymentDevice!), completion: nil)
        } else {
            log.warning("WV_DATA: rtm not yet configured to hand syncs requests, failing sync.")
            self.wvConfig.sendRtmMessage(rtmMessage: RtmMessageResponse(callbackId: self.syncCallBacks.first?.callBackId ?? 0,
                                                                        data: WVResponse.noSessionData.dictionaryRepresentation(),
                                                                        type: RtmMessageTypeVer2.sync.rawValue,
                                                                        success: false))
            self.wvConfig.showStatusMessage(.syncError, message: "Can't make sync. Session data or user is nil.")
        }
    }
    
    func handleSessionData(_ message: RtmMessage) {
        guard let data = message.data as? [String: Any] else {
            log.error("WV_DATA: Can't get data from rtmBridge message.")
            return
        }

        guard let webViewSessionData = Mapper<SessionData>().map(JSONObject: data) else {
            log.error("WV_DATA: Can't parse SessionData from rtmBridge message. Message: \(data)")
            return
        }


        self.wvConfig.webViewSessionData = webViewSessionData
        self.wvConfig.restClient = RestSession.GetUserAndDeviceWith(sessionData: webViewSessionData,
                                                                    sdkConfiguration: self.wvConfig.sdkConfiguration) { [weak self] (user, device, error) in
            guard error == nil else {
                self?.wvConfig.sendRtmMessage(rtmMessage: RtmMessageResponse(callbackId: message.callBackId,
                                                                             data: WVResponse.failed.dictionaryRepresentation(param: error.debugDescription),
                                                                             type: RtmMessageTypeVer2.userData.rawValue,
                                                                             success: false))

                self?.wvConfig.showStatusMessage(.syncError, message: "Can't get user, error: \(error.debugDescription)", error: error)
                FitpayEventsSubscriber.sharedInstance.executeCallbacksForEvent(event: .getUserAndDevice, status: .failed, reason: error)
                return
            }

            self?.wvConfig.user = user
            self?.wvConfig.device = device
            self?.wvConfig.paymentDevice?.deviceInfo?.client = self?.wvConfig.user?.client


            if let delegate = self?.wvConfig.rtmDelegate {
                delegate.didAuthorizeWithEmail(user?.email)
            }

            if self?.wvConfig.rtmConfig?.hasAccount == false {
                FitpayEventsSubscriber.sharedInstance.executeCallbacksForEvent(event: .userCreated)
            }

            FitpayEventsSubscriber.sharedInstance.executeCallbacksForEvent(event: .getUserAndDevice)

            self?.wvConfig.sendRtmMessage(rtmMessage: RtmMessageResponse(callbackId: message.callBackId,
                                                                         data: WVResponse.success.dictionaryRepresentation(),
                                                                         type: RtmMessageTypeVer2.resolve.rawValue,
                                                                         success: true))
        }
    }

    func logoutResponseMessage() -> RtmMessageResponse? {
        return RtmMessageResponse(type: RtmMessageTypeVer2.logout.rawValue)
    }

    func versionResponseMessage(version: RtmProtocolVersion) -> RtmMessageResponse? {
        return RtmMessageResponse(data: ["version":version.rawValue], type: RtmMessageTypeVer2.rtmVersion.rawValue)
    }
    
    func statusResponseMessage(message: String, type: WVMessageType) -> RtmMessageResponse? {
        return RtmMessageResponse(data: ["message": message, "type": type.rawValue], type: RtmMessageTypeVer2.deviceStatus.rawValue)
    }

    func resolveSync() {
        if let message = self.syncCallBacks.first {
            log.verbose("WV_DATA: resolving rtm sync promise.")
            if self.syncCallBacks.count > 1 {
                self.wvConfig.sendRtmMessage(rtmMessage: RtmMessageResponse(callbackId: message.callBackId, data: WVResponse.successStillWorking.dictionaryRepresentation(param: self.syncCallBacks.count), type: RtmMessageTypeVer2.sync.rawValue, success: true))
                log.verbose("WV_DATA: there was another rtm sync request, syncing again.")
            } else {
                self.wvConfig.sendRtmMessage(rtmMessage: RtmMessageResponse(callbackId: message.callBackId, data: WVResponse.success.dictionaryRepresentation(), type: RtmMessageTypeVer2.sync.rawValue, success: true))
                
                log.verbose("WV_DATA. no more rtm sync requests in queue.")
            }
            
            self.syncCallBacks.removeFirst()
        }
    }

}
