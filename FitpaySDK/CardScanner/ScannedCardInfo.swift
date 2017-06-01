//
//  ScannedCard.swift
//  FitpaySDK
//
//  Created by Anton Popovichenko on 29.05.17.
//  Copyright © 2017 Fitpay. All rights reserved.
//

import Foundation
import ObjectMapper

@objc public class ScannedCardInfo: NSObject, Mappable {
    public var cardNumber: String?
    public var expiryMonth: UInt?
    public var expiryYear: UInt?
    public var cvv: String?
    
    public override init() {
        super.init()
    }
    
    public required init?(map: Map) {
        super.init()
    }
    
    open func mapping(map: Map) {
        self.cardNumber  <- map["cardNumber"]
        self.expiryMonth <- map["expiryMonth"]
        self.expiryYear  <- map["expiryYear"]
        self.cvv         <- map["cvv"]
    }
}
