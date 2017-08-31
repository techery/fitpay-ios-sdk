//
//  IdVerificationResponse.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 30.08.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import ObjectMapper

open class IdVerificationResponse: NSObject, Mappable {
    open var oemAccountInfoUpdatedDate: Int?
    open var oemAccountCreatedDate: Int?
    open var suspendedCardsInAccount: Int?
    open var daysSinceLastAccountActivity: Int?
    open var deviceLostMode: Int?
    open var deviceWithActiveTokens: Int?
    open var activeTokenOnAllDevicesForAccount: Int?
    open var nfcCapable: Bool?

    /// between 0-9
    open var accountScore: UInt8?
    
    /// between 0-9
    open var deviceScore: UInt8?
    
    public override init() {
        super.init()
    }
    
    public required init?(map: Map) {
        super.init()
    }
    
    open func mapping(map: Map) {
        oemAccountInfoUpdatedDate <- map["oemAccountInfoUpdatedDate"]
        oemAccountCreatedDate <- map["oemAccountCreatedDate"]
        suspendedCardsInAccount <- map["suspendedCardsInAccount"]
        daysSinceLastAccountActivity <- map["daysSinceLastAccountActivity"]
        deviceLostMode <- map["deviceLostMode"]
        deviceWithActiveTokens <- map["deviceWithActiveTokens"]
        activeTokenOnAllDevicesForAccount <- map["activeTokenOnAllDevicesForAccount"]
        nfcCapable <- map["nfcCapable"]
        accountScore <- map["accountScore"]
        deviceScore <- map["deviceScore"]
    }
}
